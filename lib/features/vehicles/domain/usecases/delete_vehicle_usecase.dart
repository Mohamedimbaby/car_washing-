import '../../../../core/utils/typedef.dart';
import '../repositories/vehicle_repository.dart';

class DeleteVehicleUseCase {
  final VehicleRepository repository;

  DeleteVehicleUseCase(this.repository);

  ResultVoid call(String id) {
    return repository.deleteVehicle(id);
  }
}
