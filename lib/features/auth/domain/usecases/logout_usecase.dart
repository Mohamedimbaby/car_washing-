import '../../../../core/utils/typedef.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  ResultVoid call() {
    return repository.logout();
  }
}
