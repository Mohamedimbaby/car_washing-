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

  BookingRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _currentUserId => firebaseAuth.currentUser?.uid ?? 'guest';
  String get _appId => AppConfig.appId;

  @override
  ResultFuture<List<ServicePackageEntity>> getServicePackages(
    ServiceType serviceType,
  ) async {
    try {
      // Fetch from Firebase filtered by app_id and service type
      final snapshot = await firestore
          .collection('tenants')
          .doc(_appId)
          .collection('servicePackages')
          .where('serviceType', isEqualTo: serviceType.toString().split('.').last)
          .where('isActive', isEqualTo: true)
          .orderBy('price')
          .get();




      final packages = snapshot.docs
          .map((doc) => ServicePackageModel.fromFirestore(doc))
          .toList();

      return Right(packages);
    } catch (e) {
      // If Firebase fetch fails, use mock data
      return Right(_getMockPackages(serviceType));
    }
  }

  @override
  ResultFuture<List<AddonEntity>> getAddons() async {
    try {
      // Fetch from Firebase filtered by app_id
      final snapshot = await firestore
          .collection('tenants')
          .doc(_appId)
          .collection('addons')
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
      final slots = _getMockTimeSlots();
      return Right(slots);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<BookingEntity> createBooking({
    required String vehicleId,
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
      if (timeSlot != null && centerId.isNotEmpty) {
        final slotsBooked = await _bookConsecutiveSlots(
          providerId: centerId,
          date: scheduledDate,
          startTime: timeSlot,
          durationMinutes: packageDuration,
        );
        
        if (!slotsBooked) {
          return const Left(ServerFailure(
            'Not enough consecutive slots available for this service',
          ));
        }
      }
      
      // Store booking under tenant's bookings collection
      final docRef = firestore
          .collection('tenants')
          .doc(_appId)
          .collection('bookings')
          .doc();
      
      final totalPrice = await _calculateTotalPrice(packageId, addonIds);
      
      final bookingData = {
        'appId': _appId,
        'userId': _currentUserId,
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
        'specialInstructions': specialInstructions,
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(bookingData);

      final booking = BookingEntity(
        id: docRef.id,
        userId: _currentUserId,
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
      final snapshot = await firestore
          .collection('tenants')
          .doc(_appId)
          .collection('bookings')
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
      final doc = await firestore
          .collection('tenants')
          .doc(_appId)
          .collection('bookings')
          .doc(id)
          .get();
      
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
      await firestore
          .collection('tenants')
          .doc(_appId)
          .collection('bookings')
          .doc(id)
          .update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Helper methods for slot booking
  Future<int> _getPackageDuration(String packageId) async {
    try {
      final packageDoc = await firestore
          .collection(AppConfig.collectionPath('packages'))
          .doc(packageId)
          .get();
      
      if (packageDoc.exists) {
        final durationStr = packageDoc.data()?['duration'] as String?;
        if (durationStr != null) {
          final parts = durationStr.split(' ');
          if (parts.isNotEmpty) {
            return int.tryParse(parts[0]) ?? 30;
          }
        }
      }
      
      // Fallback to mock data
      if (packageId == 'basic') return 20;
      if (packageId == 'standard') return 40;
      if (packageId == 'premium') return 60;
      if (packageId == 'detailing') return 120;
      
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
      // Calculate number of 30-minute slots needed (updated from 15-minute)
      final slotsNeeded = (durationMinutes / 30).ceil();
      
      // Parse start time
      final timeParts = startTime.split(':');
      if (timeParts.length != 2) return false;
      
      int currentHour = int.parse(timeParts[0]);
      int currentMinute = int.parse(timeParts[1]);
      
      // Generate list of consecutive slot times needed (30-minute intervals)
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
      
      // Use Firestore transaction to ensure atomic booking
      return await firestore.runTransaction((transaction) async {
        // Get the slot document for this provider and date
        final slotId = '${providerId}_${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
        final slotDocRef = firestore
            .collection(AppConfig.collectionPath('slots'))
            .doc(slotId);
        
        final slotDoc = await transaction.get(slotDocRef);
        
        if (!slotDoc.exists) {
          throw Exception('Slot document not found');
        }
        
        final slotData = slotDoc.data() as Map<String, dynamic>;
        final slotsArray = slotData['slots'] as List<dynamic>;
        
        // Check if all required slots have available capacity
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
                break;
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
        
        if (!allAvailable) {
          return false;
        }
        
        // Book all slots by incrementing booked count
        for (final index in slotIndices) {
          slotsArray[index]['booked'] = (slotsArray[index]['booked'] as int? ?? 0) + 1;
        }
        
        // Update the document
        transaction.update(slotDocRef, {'slots': slotsArray});
        
        return true;
      });
    } catch (e) {
      print('Error booking consecutive slots: $e');
      return false;
    }
  }

  Future<double> _calculateTotalPrice(
    String packageId,
    List<String> addonIds,
  ) async {
    try {
      double total = 0;
      
      // Get package price from Firebase
      final packageDoc = await firestore
          .collection('tenants')
          .doc(_appId)
          .collection('servicePackages')
          .doc(packageId)
          .get();
      
      if (packageDoc.exists) {
        total += (packageDoc.data()?['price'] as num).toDouble();
      }
      
      // Get addon prices from Firebase
      if (addonIds.isNotEmpty) {
        final addonsSnapshot = await firestore
            .collection('tenants')
            .doc(_appId)
            .collection('addons')
            .where(FieldPath.documentId, whereIn: addonIds)
            .get();
        
        for (var doc in addonsSnapshot.docs) {
          total += (doc.data()['price'] as num).toDouble();
        }
      }
      
      return total;
    } catch (e) {
      // Fallback to mock calculation
      double total = 0;
      if (packageId == 'basic') total += 25;
      if (packageId == 'standard') total += 45;
      if (packageId == 'premium') total += 75;
      if (packageId == 'detailing') total += 150;
      total += addonIds.length * 10;
      return total;
    }
  }

  List<ServicePackageEntity> _getMockPackages(ServiceType serviceType) {
    return [
      ServicePackageEntity(
        id: 'basic',
        name: 'Basic Wash',
        description: 'Exterior wash and dry',
        price: 25.0,
        type: PackageType.basic,
        durationMinutes: 20,
        features: [
          'Exterior hand wash',
          'Tire cleaning',
          'Hand dry',
        ],
      ),
      ServicePackageEntity(
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
      ServicePackageEntity(
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
      ServicePackageEntity(
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
        name: 'Wax Protection',
        description: 'Premium wax coating',
        price: 15.0,
      ),
      const AddonEntity(
        id: 'engine',
        name: 'Engine Cleaning',
        description: 'Deep engine bay cleaning',
        price: 20.0,
      ),
      const AddonEntity(
        id: 'headlight',
        name: 'Headlight Restoration',
        description: 'Restore cloudy headlights',
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
