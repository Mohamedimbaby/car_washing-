import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  ResultFuture<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await localDataSource.saveUser(user);
      await localDataSource.saveToken(user.id);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final user = await remoteDataSource.register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      await localDataSource.saveUser(user);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<UserEntity> getCurrentUser() async {
    try {
      final localUser = await localDataSource.getUser();
      if (localUser != null) {
        return Right(localUser);
      }
      final remoteUser = await remoteDataSource.getCurrentUser();
      return Right(remoteUser);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultVoid logout() async {
    try {
      await localDataSource.clearToken();
      await localDataSource.clearUser();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  ResultFuture<bool> isLoggedIn() async {
    try {
      final token = await localDataSource.getToken();
      if (token == 'GUEST_MODE') {
        return const Right(false);
      }
      return Right(token != null);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  ResultVoid saveToken(String token) async {
    try {
      await localDataSource.saveToken(token);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  ResultFuture<String?> getToken() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
