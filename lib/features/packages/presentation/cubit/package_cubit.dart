import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_packages_usecase.dart';
import '../../domain/usecases/add_package_usecase.dart';
import '../../domain/usecases/update_package_usecase.dart';
import '../../domain/usecases/delete_package_usecase.dart';
import '../../domain/usecases/toggle_package_status_usecase.dart';
import 'package_state.dart';

class PackageCubit extends Cubit<PackageState> {
  final GetPackagesUseCase getPackagesUseCase;
  final AddPackageUseCase addPackageUseCase;
  final UpdatePackageUseCase updatePackageUseCase;
  final DeletePackageUseCase deletePackageUseCase;
  final TogglePackageStatusUseCase togglePackageStatusUseCase;

  PackageCubit({
    required this.getPackagesUseCase,
    required this.addPackageUseCase,
    required this.updatePackageUseCase,
    required this.deletePackageUseCase,
    required this.togglePackageStatusUseCase,
  }) : super(PackageInitial());

  Future<void> loadPackages() async {
    emit(PackageLoading());
    final result = await getPackagesUseCase();
    result.fold(
      (failure) => emit(PackageError(failure.message)),
      (packages) => emit(PackagesLoaded(packages)),
    );
  }

  Future<void> addPackage({
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    required double price,
    required int durationMinutes,
    required List<String> services,
    File? imageFile,
    bool isActive = true,
  }) async {
    emit(PackageLoading());
    final result = await addPackageUseCase(
      name: name,
      nameAr: nameAr,
      description: description,
      descriptionAr: descriptionAr,
      price: price,
      durationMinutes: durationMinutes,
      services: services,
      imageFile: imageFile,
      isActive: isActive,
    );
    result.fold(
      (failure) => emit(PackageError(failure.message)),
      (package) {
        emit(PackageAdded(package));
        loadPackages();
      },
    );
  }

  Future<void> updatePackage({
    required String packageId,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    double? price,
    int? durationMinutes,
    List<String>? services,
    File? imageFile,
    bool? isActive,
  }) async {
    emit(PackageLoading());
    final result = await updatePackageUseCase(
      packageId: packageId,
      name: name,
      nameAr: nameAr,
      description: description,
      descriptionAr: descriptionAr,
      price: price,
      durationMinutes: durationMinutes,
      services: services,
      imageFile: imageFile,
      isActive: isActive,
    );
    result.fold(
      (failure) => emit(PackageError(failure.message)),
      (package) {
        emit(PackageUpdated(package));
        loadPackages();
      },
    );
  }

  Future<void> deletePackage(String packageId) async {
    emit(PackageLoading());
    final result = await deletePackageUseCase(packageId);
    result.fold(
      (failure) => emit(PackageError(failure.message)),
      (_) {
        emit(PackageDeleted());
        loadPackages();
      },
    );
  }

  Future<void> toggleStatus(String packageId, bool isActive) async {
    final result = await togglePackageStatusUseCase(packageId, isActive);
    result.fold(
      (failure) => emit(PackageError(failure.message)),
      (_) => loadPackages(),
    );
  }
}
