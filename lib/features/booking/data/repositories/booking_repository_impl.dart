import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/service_package_entity.dart';
import '../../domain/entities/addon_entity.dart';
import '../../domain/entities/time_slot_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/service_package_model.dart';
import '../models/addon_model.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  BookingRepositoryImpl({required this.firestore, required this.firebaseAuth});

  String get _currentUserId => firebaseAuth.currentUser?.uid ?? 'guest';
  String get _appId => AppConfig.appId;

  CollectionReference get _bookingsCollection =>
      firestore.collection(AppConfig.collectionPath('bookings'));
  CollectionReference get _packagesCollection =>
      firestore.collection(AppConfig.collectionPath('packages'));
  CollectionReference get _addonsCollection =>
      firestore.collection(AppConfig.collectionPath('addons'));
  CollectionReference get _slotsCollection =>
      firestore.collection(AppConfig.collectionPath('slots'));

  @override
  ResultFuture<List<ServicePackageEntity>> getServicePackages(
    ServiceType serviceType,
  ) async {
    try {
      final snapshot = await _packagesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('price')
          .get();

      final packages = snapshot.docs
          .map((doc) => ServicePackageModel.fromFirestore(doc))
          .toList();

      if (packages.isEmpty) {
        return Right(_getMockPackages(serviceType));
      }

      return Right(packages);
    } catch (e) {
      return Right(_getMockPackages(serviceType));
    }
  }

  @override
  ResultFuture<List<AddonEntity>> getAddons() async {
    try {
      final snapshot = await _addonsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('price')
          .get();

      if (snapshot.docs.isEmpty) {
        return Right(_getMockAddons());
      }

      final addons = snapshot.docs
          .map((doc) => AddonModel.fromFirestore(doc))
          .toList();

      return Right(addons);
    } catch (e) {
      return Right(_getMockAddons());
    }
  }

  @override
  ResultFuture<List<TimeSlotEntity>> getAvailableTimeSlots({
    required String centerId,
    required DateTime date,
  }) async {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final snapshot = await _slotsCollection
          .where('providerId', isEqualTo: centerId)
          .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return Right(_getMockTimeSlots());
      }

      final slotDoc = snapshot.docs.first;
      final slotsArray =
          (slotDoc.data() as Map<String, dynamic>)['slots'] as List<dynamic>? ??
          [];

      final timeSlots = slotsArray.map((slot) {
        final time = slot['time'] as String? ?? '00:00';
        final capacity = slot['capacity'] as int? ?? 0;
        final booked = slot['booked'] as int? ?? 0;
        final available = capacity - booked;

        // Calculate end time (30 min later)
        final timeParts = time.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final endMinute = minute + 30;
        final endHour = hour + (endMinute >= 60 ? 1 : 0);
        final endTime =
            '${endHour.toString().padLeft(2, '0')}:${(endMinute % 60).toString().padLeft(2, '0')}';

        return TimeSlotEntity(
          id: '${slotDoc.id}_$time',
          startTime: time,
          endTime: endTime,
          isAvailable: available > 0,
          availableSlots: available,
        );
      }).toList();

      return Right(timeSlots);
    } catch (e) {
      return Right(_getMockTimeSlots());
    }
  }

  @override
  ResultFuture<BookingEntity> createBooking({
    required String vehicleId,
    required String providerId,
    required String centerId,
    String? branchId,
    required ServiceType serviceType,
    required String packageId,
    required List<String> addonIds,
    required DateTime scheduledDate,
    String? timeSlot,
    String? specialInstructions,
    String? location,
  }) async {
    try {
      // Get package duration to calculate required slots
      final packageDuration = await _getPackageDuration(packageId);

      // Check and book consecutive slots if timeSlot is provided
      if (timeSlot != null && providerId.isNotEmpty) {
        final slotsBooked = await _bookConsecutiveSlots(
          providerId: providerId,
          date: scheduledDate,
          startTime: timeSlot,
          durationMinutes: packageDuration,
        );

        if (!slotsBooked) {
          return const Left(
            ServerFailure(
              'Not enough consecutive slots available for this service',
            ),
          );
        }
      }

      final docRef = _bookingsCollection.doc();
      final totalPrice = await _calculateTotalPrice(packageId, addonIds);

      final bookingData = {
        'appId': _appId,
        'userId': _currentUserId,
        'providerId': providerId,
        'vehicleId': vehicleId,
        'centerId': centerId,
        'branchId': branchId,
        'serviceType': serviceType.toString().split('.').last,
        'packageId': packageId,
        'addonIds': addonIds,
        'scheduledDate': Timestamp.fromDate(scheduledDate),
        'timeSlot': timeSlot,
        'status': 'pending',
        'totalPrice': totalPrice,
        'currency': 'EGP',
        'specialInstructions': specialInstructions,
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(bookingData);

      final booking = BookingEntity(
        id: docRef.id,
        userId: _currentUserId,
        providerId: providerId,
        vehicleId: vehicleId,
        centerId: centerId,
        branchId: branchId,
        serviceType: serviceType,
        packageId: packageId,
        addonIds: addonIds,
        scheduledDate: scheduledDate,
        timeSlot: timeSlot,
        status: BookingStatus.pending,
        totalPrice: totalPrice,
        currency: 'EGP',
        specialInstructions: specialInstructions,
        location: location,
        createdAt: DateTime.now(),
      );

      return Right(booking);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<BookingEntity>> getBookings() async {
    try {
      final snapshot = await _bookingsCollection
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      final bookings = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();

      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<BookingEntity> getBookingById(String id) async {
    try {
      final doc = await _bookingsCollection.doc(id).get();

      if (!doc.exists) {
        return const Left(ServerFailure('Booking not found'));
      }

      final booking = BookingModel.fromFirestore(doc);
      return Right(booking);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid cancelBooking(String id) async {
    try {
      await _bookingsCollection.doc(id).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // --- Helper methods ---

  Future<int> _getPackageDuration(String packageId) async {
    try {
      final packageDoc = await _packagesCollection.doc(packageId).get();

      if (packageDoc.exists) {
        final data = packageDoc.data() as Map<String, dynamic>?;
        final duration = data?['duration'];
        if (duration is int) return duration;
        if (duration is String) {
          final parts = duration.split(' ');
          if (parts.isNotEmpty) {
            return int.tryParse(parts[0]) ?? 30;
          }
        }
      }

      return 30; // Default 30 minutes
    } catch (e) {
      return 30;
    }
  }

  Future<bool> _bookConsecutiveSlots({
    required String providerId,
    required DateTime date,
    required String startTime,
    required int durationMinutes,
  }) async {
    try {
      final slotsNeeded = (durationMinutes / 30).ceil();

      final timeParts = startTime.split(':');
      if (timeParts.length != 2) return false;

      int currentHour = int.parse(timeParts[0]);
      int currentMinute = int.parse(timeParts[1]);

      final List<String> requiredSlotTimes = [];
      for (int i = 0; i < slotsNeeded; i++) {
        requiredSlotTimes.add(
          '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}',
        );

        currentMinute += 30;
        if (currentMinute >= 60) {
          currentMinute = 0;
          currentHour++;
        }
      }

      final dateOnly = DateTime(date.year, date.month, date.day);

      return await firestore.runTransaction((transaction) async {
        final querySnapshot = await _slotsCollection
            .where('providerId', isEqualTo: providerId)
            .where('appId', isEqualTo: _appId)
            .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          return false;
        }

        final slotDoc = querySnapshot.docs.first;
        final slotData = slotDoc.data() as Map<String, dynamic>;
        final slotsArray = slotData['slots'] as List<dynamic>;

        bool allAvailable = true;
        final List<int> slotIndices = [];

        for (final requiredTime in requiredSlotTimes) {
          int slotIndex = -1;
          for (int i = 0; i < slotsArray.length; i++) {
            final slot = slotsArray[i] as Map<String, dynamic>;
            if (slot['time'] == requiredTime) {
              slotIndex = i;
              final booked = slot['booked'] as int? ?? 0;
              final capacity = slot['capacity'] as int? ?? 0;

              if (booked >= capacity) {
                allAvailable = false;
              }
              break;
            }
          }

          if (slotIndex == -1) {
            allAvailable = false;
            break;
          }

          slotIndices.add(slotIndex);
        }

        if (!allAvailable) return false;

        for (final index in slotIndices) {
          slotsArray[index]['booked'] =
              (slotsArray[index]['booked'] as int? ?? 0) + 1;
        }

        transaction.update(slotDoc.reference, {'slots': slotsArray});

        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<double> _calculateTotalPrice(
    String packageId,
    List<String> addonIds,
  ) async {
    try {
      double total = 0;

      final packageDoc = await _packagesCollection.doc(packageId).get();

      if (packageDoc.exists) {
        total +=
            ((packageDoc.data() as Map<String, dynamic>?)?['price'] as num?)
                ?.toDouble() ??
            0;
      }

      if (addonIds.isNotEmpty) {
        final addonsSnapshot = await _addonsCollection
            .where(FieldPath.documentId, whereIn: addonIds)
            .get();

        for (var doc in addonsSnapshot.docs) {
          total +=
              ((doc.data() as Map<String, dynamic>)['price'] as num?)
                  ?.toDouble() ??
              0;
        }
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  // --- Mock data fallbacks (kept for offline/demo) ---

  List<ServicePackageEntity> _getMockPackages(ServiceType serviceType) {
    return [
      const ServicePackageEntity(
        id: 'basic',
        name: 'Basic Wash',
        description: 'Exterior wash and dry',
        price: 25.0,
        type: PackageType.basic,
        durationMinutes: 20,
        features: ['Exterior hand wash', 'Tire cleaning', 'Hand dry'],
      ),
      const ServicePackageEntity(
        id: 'standard',
        name: 'Standard Wash',
        description: 'Exterior wash, wheels, and interior vacuum',
        price: 45.0,
        type: PackageType.standard,
        durationMinutes: 40,
        features: [
          'Everything in Basic',
          'Wheel detailing',
          'Interior vacuum',
          'Window cleaning',
        ],
      ),
      const ServicePackageEntity(
        id: 'premium',
        name: 'Premium Wash',
        description: 'Complete wash and interior cleaning',
        price: 75.0,
        type: PackageType.premium,
        durationMinutes: 60,
        features: [
          'Everything in Standard',
          'Interior wipe down',
          'Dashboard polish',
          'Air freshener',
          'Tire shine',
        ],
      ),
      const ServicePackageEntity(
        id: 'detailing',
        name: 'Full Detailing',
        description: 'Complete professional detailing service',
        price: 150.0,
        type: PackageType.detailing,
        durationMinutes: 120,
        features: [
          'Everything in Premium',
          'Clay bar treatment',
          'Wax application',
          'Engine cleaning',
          'Leather conditioning',
          'Complete interior detailing',
        ],
      ),
    ];
  }

  List<AddonEntity> _getMockAddons() {
    return [
      const AddonEntity(
        id: 'wax',
        providerId: 'mock',
        appId: 'mock',
        name: 'Wax Protection',
        nameAr: 'حماية الشمع',
        description: 'Premium wax coating',
        descriptionAr: 'طبقة شمع ممتازة',
        price: 15.0,
      ),
      const AddonEntity(
        id: 'engine',
        providerId: 'mock',
        appId: 'mock',
        name: 'Engine Cleaning',
        nameAr: 'تنظيف المحرك',
        description: 'Deep engine bay cleaning',
        descriptionAr: 'تنظيف عميق لغرفة المحرك',
        price: 20.0,
      ),
      const AddonEntity(
        id: 'headlight',
        providerId: 'mock',
        appId: 'mock',
        name: 'Headlight Restoration',
        nameAr: 'تلميع المصابيح',
        description: 'Restore cloudy headlights',
        descriptionAr: 'استعادة لمعان المصابيح',
        price: 25.0,
      ),
    ];
  }

  List<TimeSlotEntity> _getMockTimeSlots() {
    return [
      const TimeSlotEntity(
        id: 'slot1',
        startTime: '09:00',
        endTime: '10:00',
        isAvailable: true,
        availableSlots: 3,
      ),
      const TimeSlotEntity(
        id: 'slot2',
        startTime: '10:00',
        endTime: '11:00',
        isAvailable: true,
        availableSlots: 2,
      ),
      const TimeSlotEntity(
        id: 'slot3',
        startTime: '11:00',
        endTime: '12:00',
        isAvailable: false,
        availableSlots: 0,
      ),
      const TimeSlotEntity(
        id: 'slot4',
        startTime: '14:00',
        endTime: '15:00',
        isAvailable: true,
        availableSlots: 5,
      ),
    ];
  }
}
