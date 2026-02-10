import '../../../../core/utils/typedef.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  ResultFuture<UserEntity> call({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) {
    return repository.register(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
  }
}
