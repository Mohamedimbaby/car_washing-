import '../../../../core/utils/typedef.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  ResultFuture<UserEntity> login({
    required String email,
    required String password,
  });

  ResultFuture<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  });

  ResultFuture<UserEntity> getCurrentUser();
  
  ResultVoid logout();
  
  ResultFuture<bool> isLoggedIn();
  
  ResultVoid saveToken(String token);
  
  ResultFuture<String?> getToken();
}
