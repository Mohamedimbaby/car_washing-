import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    
    // Check if guest mode is enabled
    final guestResult = await authRepository.getToken();
    await guestResult.fold(
      (failure) {},
      (token) async {
        if (token == 'GUEST_MODE') {
          emit(GuestMode());
          return;
        }
      },
    );
    
    final result = await authRepository.isLoggedIn();
    result.fold(
      (failure) => emit(Unauthenticated()),
      (isLoggedIn) {
        if (isLoggedIn) {
          _loadCurrentUser();
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _loadCurrentUser() async {
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await loginUseCase(
      email: email,
      password: password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    emit(AuthLoading());
    final result = await registerUseCase(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(RegistrationSuccess(user)),
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> continueAsGuest() async {
    emit(AuthLoading());
    // Save guest mode token
    await authRepository.saveToken('GUEST_MODE');
    emit(GuestMode());
  }
}
