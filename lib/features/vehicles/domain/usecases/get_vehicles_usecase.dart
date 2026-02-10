import '../../../../core/utils/typedef.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class GetVehiclesUseCase {
  final VehicleRepository repository;

  GetVehiclesUseCase(this.repository);

  ResultFuture<List<VehicleEntity>> call() {
    return repository.getVehicles();
  }
}
