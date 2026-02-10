import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vehicle_model.dart';

abstract class VehicleFirebaseDataSource {
  Future<List<VehicleModel>> getVehicles();
  Future<VehicleModel> addVehicle({
    required String make,
    required String model,
    required String color,
    required String licensePlate,
    required int year,
  });
  Future<void> deleteVehicle(String id);
  Future<void> setDefaultVehicle(String id);
}

class VehicleFirebaseDataSourceImpl implements VehicleFirebaseDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  VehicleFirebaseDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _currentUserId => firebaseAuth.currentUser!.uid;

  @override
  Future<List<VehicleModel>> getVehicles() async {
    try {
      final snapshot = await firestore
          .collection('vehicles')
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return VehicleModel.fromJson({
          'id': doc.id,
          ...data,
          'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get vehicles: $e');
    }
  }

  @override
  Future<VehicleModel> addVehicle({
    required String make,
    required String model,
    required String color,
    required String licensePlate,
    required int year,
  }) async {
    try {
      final docRef = firestore.collection('vehicles').doc();
      final vehicleData = {
        'userId': _currentUserId,
        'make': make,
        'model': model,
        'color': color,
        'licensePlate': licensePlate,
        'year': year,
        'isDefault': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(vehicleData);

      return VehicleModel(
        id: docRef.id,
        userId: _currentUserId,
        make: make,
        model: model,
        color: color,
        licensePlate: licensePlate,
        year: year,
        isDefault: false,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await firestore.collection('vehicles').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  @override
  Future<void> setDefaultVehicle(String id) async {
    try {
      final batch = firestore.batch();

      // Set all vehicles to non-default
      final vehicles = await firestore
          .collection('vehicles')
          .where('userId', isEqualTo: _currentUserId)
          .get();

      for (var doc in vehicles.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Set selected vehicle as default
      batch.update(
        firestore.collection('vehicles').doc(id),
        {'isDefault': true},
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to set default vehicle: $e');
    }
  }
}
