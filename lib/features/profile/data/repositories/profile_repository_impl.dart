import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage storage;

  ProfileRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.storage,
  });

  String get _currentUserId => firebaseAuth.currentUser!.uid;
  String get _appId => AppConfig.appId;
  CollectionReference get _usersCollection =>
      firestore.collection(AppConfig.collectionPath('users'));

  @override
  ResultFuture<UserProfileEntity> getUserProfile() async {
    try {
      final doc = await _usersCollection.doc(_currentUserId).get();

      if (!doc.exists) {
        // Create default profile if doesn't exist
        final user = firebaseAuth.currentUser!;
        final profile = UserProfileModel(
          userId: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          phone: user.phoneNumber,
          profilePhoto: user.photoURL,
          registrationDate: DateTime.now(),
          appId: _appId,
        );

        await _usersCollection.doc(_currentUserId).set(profile.toFirestore());
        return Right(profile);
      }

      final profile = UserProfileModel.fromFirestore(doc);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<UserProfileEntity> updateProfile({
    String? name,
    String? phone,
    String? address,
    File? profilePhotoFile,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;

      // Upload photo if provided
      if (profilePhotoFile != null) {
        final photoUrlResult = await uploadProfilePhoto(profilePhotoFile);
        await photoUrlResult.fold(
          (failure) => throw Exception(failure.message),
          (photoUrl) async {
            updateData['profilePhoto'] = photoUrl;
            
            // Update Firebase Auth profile
            await firebaseAuth.currentUser?.updatePhotoURL(photoUrl);
          },
        );
      }

      // Update display name if provided
      if (name != null) {
        await firebaseAuth.currentUser?.updateDisplayName(name);
      }

      await _usersCollection.doc(_currentUserId).update(updateData);

      // Fetch updated profile
      final doc = await _usersCollection.doc(_currentUserId).get();
      final profile = UserProfileModel.fromFirestore(doc);

      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<String> uploadProfilePhoto(File photoFile) async {
    try {
      // Compress image
      final bytes = await photoFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if too large
      if (image.width > 500) {
        image = img.copyResize(image, width: 500);
      }

      // Compress to JPEG
      final compressedBytes = img.encodeJpg(image, quality: 85);

      // Upload to Storage
      final ref = storage.ref().child(
            'apps/$_appId/user_photos/$_currentUserId/profile.jpg',
          );

      await ref.putData(compressedBytes);
      final downloadUrl = await ref.getDownloadURL();

      return Right(downloadUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
