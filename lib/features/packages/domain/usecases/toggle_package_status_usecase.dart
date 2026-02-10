import '../../../../core/utils/typedef.dart';
import '../repositories/package_repository.dart';

class TogglePackageStatusUseCase {
  final PackageRepository repository;

  TogglePackageStatusUseCase(this.repository);

  ResultVoid call(String packageId, bool isActive) {
    return repository.togglePackageStatus(packageId, isActive);
  }
}
