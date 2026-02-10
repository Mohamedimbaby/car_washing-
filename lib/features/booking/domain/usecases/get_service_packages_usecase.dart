import '../../../../core/utils/typedef.dart';
import '../entities/service_package_entity.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetServicePackagesUseCase {
  final BookingRepository repository;

  GetServicePackagesUseCase(this.repository);

  ResultFuture<List<ServicePackageEntity>> call(ServiceType serviceType) {
    return repository.getServicePackages(serviceType);
  }
}
