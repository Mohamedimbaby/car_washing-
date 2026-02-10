import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/car_entity.dart';
import '../../domain/repositories/car_repository.dart';
import '../models/car_model.dart';

class CarRepositoryImpl implements CarRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage storage;

  CarRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.storage,
  });

  String get _currentUserId => firebaseAuth.currentUser!.uid;
  String get _appId => AppConfig.appId;
  CollectionReference get _carsCollection =>
      firestore.collection(AppConfig.collectionPath('cars'));

  @override
  ResultFuture<List<CarEntity>> getCars() async {
    try {
      final snapshot = await _carsCollection
          .where('userId', isEqualTo: _currentUserId)
          .where('appId', isEqualTo: _appId)
          .orderBy('createdAt', descending: true)
          .get();

      final cars = snapshot.docs
          .map((doc) => CarModel.fromFirestore(doc))
          .toList();

      return Right(cars);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<CarEntity> getCarById(String carId) async {
    try {
      final doc = await _carsCollection.doc(carId).get();

      if (!doc.exists) {
        return const Left(ServerFailure('Car not found'));
      }

      final car = CarModel.fromFirestore(doc);
      return Right(car);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<CarEntity> addCar({
    required String plateNumber,
    required String brand,
    required String model,
    required String color,
    required int year,
    required File imageFile,
    bool isDefault = false,
  }) async {
    try {
      // Compress and upload image
      final imageUrl = await _uploadCarImage(imageFile);

      // If this is the first car or set as default, make it default
      final carsSnapshot = await _carsCollection
          .where('userId', isEqualTo: _currentUserId)
          .where('appId', isEqualTo: _appId)
          .limit(1)
          .get();

      final isFirstCar = carsSnapshot.docs.isEmpty;
      final shouldBeDefault = isDefault || isFirstCar;

      // If setting as default, unset other defaults
      if (shouldBeDefault) {
        await _unsetOtherDefaults();
      }

      final docRef = _carsCollection.doc();
      final carData = {
        'userId': _currentUserId,
        'appId': _appId,
        'plateNumber': plateNumber,
        'brand': brand,
        'model': model,
        'color': color,
        'year': year,
        'imageUrl': imageUrl,
        'isDefault': shouldBeDefault,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(carData);

      final car = CarEntity(
        id: docRef.id,
        userId: _currentUserId,
        appId: _appId,
        plateNumber: plateNumber,
        brand: brand,
        model: model,
        color: color,
        year: year,
        imageUrl: imageUrl,
        isDefault: shouldBeDefault,
        createdAt: DateTime.now(),
      );

      return Right(car);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<CarEntity> updateCar({
    required String carId,
    String? plateNumber,
    String? brand,
    String? model,
    String? color,
    int? year,
    File? imageFile,
    bool? isDefault,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (plateNumber != null) updateData['plateNumber'] = plateNumber;
      if (brand != null) updateData['brand'] = brand;
      if (model != null) updateData['model'] = model;
      if (color != null) updateData['color'] = color;
      if (year != null) updateData['year'] = year;
      if (isDefault != null) updateData['isDefault'] = isDefault;

      // Upload new image if provided
      if (imageFile != null) {
        final imageUrl = await _uploadCarImage(imageFile, carId: carId);
        updateData['imageUrl'] = imageUrl;
      }

      // If setting as default, unset others
      if (isDefault == true) {
        await _unsetOtherDefaults();
      }

      await _carsCollection.doc(carId).update(updateData);

      final doc = await _carsCollection.doc(carId).get();
      final car = CarModel.fromFirestore(doc);

      return Right(car);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid deleteCar(String carId) async {
    try {
      // Get car data to delete image from storage
      final doc = await _carsCollection.doc(carId).get();
      final data = doc.data() as Map<String, dynamic>?;
      final imageUrl = data?['imageUrl'] as String?;

      // Delete from Firestore
      await _carsCollection.doc(carId).delete();

      // Delete image from Storage
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final ref = storage.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          // Ignore storage deletion errors
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid setDefaultCar(String carId) async {
    try {
      // Unset all other defaults
      await _unsetOtherDefaults();

      // Set this car as default
      await _carsCollection.doc(carId).update({'isDefault': true});

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Upload car image to Firebase Storage with compression
  Future<String> _uploadCarImage(File imageFile, {String? carId}) async {
    // Compress image (max 1MB)
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize if too large
    if (image.width > 1024) {
      image = img.copyResize(image, width: 1024);
    }

    // Compress to JPEG
    final compressedBytes = img.encodeJpg(image, quality: 85);

    // Check size (should be < 1MB)
    if (compressedBytes.length > 1024 * 1024) {
      // Compress more aggressively
      final moreCompressed = img.encodeJpg(image, quality: 70);
      if (moreCompressed.length > 1024 * 1024) {
        throw Exception('Image too large even after compression');
      }
    }

    // Upload to Storage
    final fileName = carId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final ref = storage.ref().child(
          'apps/$_appId/car_images/$_currentUserId/$fileName.jpg',
        );

    await ref.putData(compressedBytes);
    final downloadUrl = await ref.getDownloadURL();

    return downloadUrl;
  }

  /// Unset all other cars as default for current user
  Future<void> _unsetOtherDefaults() async {
    final snapshot = await _carsCollection
        .where('userId', isEqualTo: _currentUserId)
        .where('appId', isEqualTo: _appId)
        .where('isDefault', isEqualTo: true)
        .get();

    final batch = firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }
}
