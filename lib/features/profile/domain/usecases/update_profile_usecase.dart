import 'dart:io';
import '../../../../core/utils/typedef.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  ResultFuture<UserProfileEntity> call({
    String? name,
    String? phone,
    String? address,
    File? profilePhotoFile,
  }) {
    return repository.updateProfile(
      name: name,
      phone: phone,
      address: address,
      profilePhotoFile: profilePhotoFile,
    );
  }
}
