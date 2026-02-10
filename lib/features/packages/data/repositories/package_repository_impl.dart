import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/package_entity.dart';
import '../../domain/repositories/package_repository.dart';
import '../models/package_model.dart';

class PackageRepositoryImpl implements PackageRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage storage;

  PackageRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.storage,
  });

  String get _currentProviderId => firebaseAuth.currentUser!.uid;
  String get _appId => AppConfig.appId;
  CollectionReference get _packagesCollection =>
      firestore.collection(AppConfig.collectionPath('packages'));

  @override
  ResultFuture<List<PackageEntity>> getPackages() async {
    try {
      final snapshot = await _packagesCollection
          .where('providerId', isEqualTo: _currentProviderId)
          .where('appId', isEqualTo: _appId)
          .orderBy('createdAt', descending: true)
          .get();

      final packages = snapshot.docs
          .map((doc) => PackageModel.fromFirestore(doc))
          .toList();

      return Right(packages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<PackageEntity> getPackageById(String packageId) async {
    try {
      final doc = await _packagesCollection.doc(packageId).get();

      if (!doc.exists) {
        return const Left(ServerFailure('Package not found'));
      }

      final package = PackageModel.fromFirestore(doc);
      return Right(package);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<PackageEntity> addPackage({
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    required double price,
    required int durationMinutes,
    required List<String> services,
    File? imageFile,
    bool isActive = true,
  }) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadPackageImage(imageFile);
      }

      final docRef = _packagesCollection.doc();
      final packageData = {
        'providerId': _currentProviderId,
        'appId': _appId,
        'name': name,
        'nameAr': nameAr,
        'description': description,
        'descriptionAr': descriptionAr,
        'price': price,
        'currency': 'EGP',
        'duration': durationMinutes,
        'services': services,
        'imageUrl': imageUrl,
        'isActive': isActive,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(packageData);

      final package = PackageEntity(
        id: docRef.id,
        providerId: _currentProviderId,
        appId: _appId,
        name: name,
        nameAr: nameAr,
        description: description,
        descriptionAr: descriptionAr,
        price: price,
        durationMinutes: durationMinutes,
        services: services,
        imageUrl: imageUrl,
        isActive: isActive,
        createdAt: DateTime.now(),
      );

      return Right(package);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<PackageEntity> updatePackage({
    required String packageId,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    double? price,
    int? durationMinutes,
    List<String>? services,
    File? imageFile,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (nameAr != null) updateData['nameAr'] = nameAr;
      if (description != null) updateData['description'] = description;
      if (descriptionAr != null) updateData['descriptionAr'] = descriptionAr;
      if (price != null) updateData['price'] = price;
      if (durationMinutes != null) updateData['duration'] = durationMinutes;
      if (services != null) updateData['services'] = services;
      if (isActive != null) updateData['isActive'] = isActive;

      if (imageFile != null) {
        final imageUrl = await _uploadPackageImage(imageFile, packageId: packageId);
        updateData['imageUrl'] = imageUrl;
      }

      await _packagesCollection.doc(packageId).update(updateData);

      final doc = await _packagesCollection.doc(packageId).get();
      final package = PackageModel.fromFirestore(doc);

      return Right(package);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid deletePackage(String packageId) async {
    try {
      // Get package data to delete image
      final doc = await _packagesCollection.doc(packageId).get();
      final data = doc.data() as Map<String, dynamic>?;
      final imageUrl = data?['imageUrl'] as String?;

      // Delete from Firestore
      await _packagesCollection.doc(packageId).delete();

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
  ResultVoid togglePackageStatus(String packageId, bool isActive) async {
    try {
      await _packagesCollection.doc(packageId).update({'isActive': isActive});
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<int> getPackageBookingCount(String packageId) async {
    try {
      final bookingsSnapshot = await firestore
          .collection(AppConfig.collectionPath('bookings'))
          .where('packageId', isEqualTo: packageId)
          .where('appId', isEqualTo: _appId)
          .get();

      return Right(bookingsSnapshot.docs.length);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Upload package image to Firebase Storage with compression
  Future<String> _uploadPackageImage(File imageFile, {String? packageId}) async {
    // Compress image
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize if too large
    if (image.width > 800) {
      image = img.copyResize(image, width: 800);
    }

    // Compress to JPEG
    final compressedBytes = img.encodeJpg(image, quality: 85);

    // Upload to Storage
    final fileName = packageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final ref = storage.ref().child(
          'apps/$_appId/package_images/$_currentProviderId/$fileName.jpg',
        );

    await ref.putData(compressedBytes);
    final downloadUrl = await ref.getDownloadURL();

    return downloadUrl;
  }
}
