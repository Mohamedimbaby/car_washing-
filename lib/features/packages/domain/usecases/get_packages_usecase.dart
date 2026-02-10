import '../../../../core/utils/typedef.dart';
import '../entities/package_entity.dart';
import '../repositories/package_repository.dart';

class GetPackagesUseCase {
  final PackageRepository repository;

  GetPackagesUseCase(this.repository);

  ResultFuture<List<PackageEntity>> call() {
    return repository.getPackages();
  }
}
