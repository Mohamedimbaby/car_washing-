import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileCubit({
    required this.getUserProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    final result = await getUserProfileUseCase();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
    File? profilePhotoFile,
  }) async {
    emit(ProfileLoading());
    final result = await updateProfileUseCase(
      name: name,
      phone: phone,
      address: address,
      profilePhotoFile: profilePhotoFile,
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) {
        emit(ProfileUpdated(profile));
        emit(ProfileLoaded(profile)); // Immediately show updated profile
      },
    );
  }
}
