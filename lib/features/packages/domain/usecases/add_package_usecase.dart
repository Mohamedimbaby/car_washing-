import 'dart:io';
import '../../../../core/utils/typedef.dart';
import '../entities/package_entity.dart';
import '../repositories/package_repository.dart';

class AddPackageUseCase {
  final PackageRepository repository;

  AddPackageUseCase(this.repository);

  ResultFuture<PackageEntity> call({
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    required double price,
    required int durationMinutes,
    required List<String> services,
    File? imageFile,
    bool isActive = true,
  }) {
    return repository.addPackage(
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
  }
}
