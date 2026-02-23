import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/config/app_config.dart';
import '../../../booking/domain/entities/booking_entity.dart';

abstract class BookingFirebaseDataSource {
  Future<String> createBooking({
    required String vehicleId,
    required String providerId,
    required String centerId,
    required ServiceType serviceType,
    required String packageId,
    required DateTime scheduledDate,
    String? timeSlot,
    double? totalPrice,
  });

  Future<List<Map<String, dynamic>>> getBookings();
  Future<void> cancelBooking(String id);
}

class BookingFirebaseDataSourceImpl implements BookingFirebaseDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  BookingFirebaseDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _currentUserId => firebaseAuth.currentUser!.uid;

  CollectionReference get _bookingsCollection =>
      firestore.collection(AppConfig.collectionPath('bookings'));

  @override
  Future<String> createBooking({
    required String vehicleId,
    required String providerId,
    required String centerId,
    required ServiceType serviceType,
    required String packageId,
    required DateTime scheduledDate,
    String? timeSlot,
    double? totalPrice,
  }) async {
    try {
      final docRef = _bookingsCollection.doc();

      await docRef.set({
        'appId': AppConfig.appId,
        'userId': _currentUserId,
        'providerId': providerId,
        'vehicleId': vehicleId,
        'centerId': centerId,
        'serviceType': serviceType.toString().split('.').last,
        'packageId': packageId,
        'scheduledDate': Timestamp.fromDate(scheduledDate),
        'timeSlot': timeSlot,
        'status': 'pending',
        'totalPrice': totalPrice ?? 0,
        'currency': 'EGP',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBookings() async {
    try {
      final snapshot = await _bookingsCollection
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...(doc.data() as Map<String, dynamic>)};
      }).toList();
    } catch (e) {
      throw Exception('Failed to get bookings: $e');
    }
  }

  @override
  Future<void> cancelBooking(String id) async {
    try {
      await _bookingsCollection.doc(id).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }
}
