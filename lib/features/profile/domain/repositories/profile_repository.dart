import 'dart:io';
import '../../../../core/utils/typedef.dart';
import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  /// Get user profile
  ResultFuture<UserProfileEntity> getUserProfile();

  /// Update user profile
  ResultFuture<UserProfileEntity> updateProfile({
    String? name,
    String? phone,
    String? address,
    File? profilePhotoFile,
  });

  /// Upload profile photo
  ResultFuture<String> uploadProfilePhoto(File photoFile);
}
