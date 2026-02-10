import '../../../../core/utils/typedef.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  ResultFuture<UserProfileEntity> call() {
    return repository.getUserProfile();
  }
}
