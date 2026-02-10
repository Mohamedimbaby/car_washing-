import 'dart:io';
import '../../../../core/utils/typedef.dart';
import '../entities/package_entity.dart';
import '../repositories/package_repository.dart';

class UpdatePackageUseCase {
  final PackageRepository repository;

  UpdatePackageUseCase(this.repository);

  ResultFuture<PackageEntity> call({
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
  }) {
    return repository.updatePackage(
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
  }
}
