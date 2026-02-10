import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../../booking/domain/entities/booking_entity.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/provider_stats_entity.dart';
import '../../domain/repositories/provider_repository.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ProviderRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _currentProviderId => firebaseAuth.currentUser!.uid;
  String get _appId => AppConfig.appId;
  CollectionReference get _bookingsCollection =>
      firestore.collection(AppConfig.collectionPath('bookings'));

  @override
  ResultFuture<ProviderStatsEntity> getProviderStats() async {
    try {
      // Get all bookings for this provider
      final bookingsSnapshot = await _bookingsCollection
          .where('providerId', isEqualTo: _currentProviderId)
          .where('appId', isEqualTo: _appId)
          .get();

      // Calculate stats
      int pendingCount = 0;
      int completedCount = 0;
      double totalIncome = 0;
      final Set<String> uniqueCustomers = {};

      for (var doc in bookingsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String?;
        final userId = data['userId'] as String?;
        final price = (data['totalPrice'] as num?)?.toDouble() ?? 0;

        if (status == 'pending') {
          pendingCount++;
        } else if (status == 'completed') {
          completedCount++;
          totalIncome += price;
        }

        if (userId != null) {
          uniqueCustomers.add(userId);
        }
      }

      // Get active packages count
      final packagesSnapshot = await firestore
          .collection(AppConfig.collectionPath('packages'))
          .where('providerId', isEqualTo: _currentProviderId)
          .where('appId', isEqualTo: _appId)
          .where('isActive', isEqualTo: true)
          .get();

      final stats = ProviderStatsEntity(
        pendingBookings: pendingCount,
        completedBookings: completedCount,
        totalIncome: totalIncome,
        totalCustomers: uniqueCustomers.length,
        activePackages: packagesSnapshot.docs.length,
      );

      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<BookingEntity>> getBookingsStream({String? status}) {
    Query query = _bookingsCollection
        .where('providerId', isEqualTo: _currentProviderId)
        .where('appId', isEqualTo: _appId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  ResultFuture<List<BookingEntity>> getRecentBookings({int limit = 5}) async {
    try {
      final snapshot = await _bookingsCollection
          .where('providerId', isEqualTo: _currentProviderId)
          .where('appId', isEqualTo: _appId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
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
  ResultVoid confirmBooking(String bookingId) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'status': 'confirmed',
        'confirmedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid completeBooking(String bookingId) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid reportBooking({
    required String bookingId,
    required List<String> reasons,
    required String details,
  }) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'status': 'reported',
        'reportedAt': FieldValue.serverTimestamp(),
        'reportReasons': reasons,
        'reportDetails': details,
        'reportedBy': _currentProviderId,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<CustomerEntity>> getCustomers() async {
    try {
      // Get all bookings for this provider
      final bookingsSnapshot = await _bookingsCollection
          .where('providerId', isEqualTo: _currentProviderId)
          .where('appId', isEqualTo: _appId)
          .get();

      if (bookingsSnapshot.docs.isEmpty) {
        return const Right([]);
      }

      // Group by userId and aggregate data
      final customerMap = <String, Map<String, dynamic>>{};
      
      for (var doc in bookingsSnapshot.docs) {
        final booking = BookingModel.fromFirestore(doc);
        final userId = booking.userId;

        if (!customerMap.containsKey(userId)) {
          customerMap[userId] = {
            'totalBookings': 0,
            'totalRevenue': 0.0,
            'lastBookingDate': booking.scheduledDate,
          };
        }

        final currentData = customerMap[userId]!;
        currentData['totalBookings'] = (currentData['totalBookings'] as int) + 1;
        
        if (booking.status == BookingStatus.completed) {
          currentData['totalRevenue'] = 
              (currentData['totalRevenue'] as double) + booking.totalPrice;
        }

        final existingDate = currentData['lastBookingDate'] as DateTime;
        if (booking.scheduledDate.isAfter(existingDate)) {
          currentData['lastBookingDate'] = booking.scheduledDate;
        }
      }

      // Convert to CustomerEntity list and fetch user info
      final customers = <CustomerEntity>[];
      
      for (var entry in customerMap.entries) {
        final userId = entry.key;
        final data = entry.value;
        
        // Fetch user info from Firestore
        String name = 'Unknown';
        String email = '';
        
        try {
          final userDoc = await firestore
              .collection('apps')
              .doc(_appId)
              .collection('users')
              .doc(userId)
              .get();
          
          if (userDoc.exists) {
            final userData = userDoc.data();
            name = userData?['name'] ?? 'Unknown';
            email = userData?['email'] ?? '';
          }
        } catch (e) {
          print('Error fetching user info: $e');
        }
        
        customers.add(CustomerEntity(
          userId: userId,
          name: name,
          email: email,
          totalBookings: data['totalBookings'] as int,
          totalRevenue: data['totalRevenue'] as double,
          lastBookingDate: data['lastBookingDate'] as DateTime,
        ));
      }

      // Sort by total bookings (descending)
      customers.sort((a, b) => b.totalBookings.compareTo(a.totalBookings));

      return Right(customers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<BookingEntity>> getCustomerBookings(String userId) async {
    try {
      final snapshot = await _bookingsCollection
          .where('providerId', isEqualTo: _currentProviderId)
          .where('userId', isEqualTo: userId)
          .where('appId', isEqualTo: _appId)
          .orderBy('bookingDate', descending: true)
          .get();

      final bookings = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();

      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
