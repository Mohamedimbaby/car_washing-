import '../../../../core/utils/typedef.dart';
import '../repositories/package_repository.dart';

class DeletePackageUseCase {
  final PackageRepository repository;

  DeletePackageUseCase(this.repository);

  ResultVoid call(String packageId) {
    return repository.deletePackage(packageId);
  }
}
