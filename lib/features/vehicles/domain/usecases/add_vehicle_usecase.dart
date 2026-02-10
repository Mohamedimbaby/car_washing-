import '../../../../core/utils/typedef.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class AddVehicleUseCase {
  final VehicleRepository repository;

  AddVehicleUseCase(this.repository);

  ResultFuture<VehicleEntity> call({
    required String make,
    required String model,
    required String color,
    required String licensePlate,
    required int year,
    String? imageUrl,
  }) {
    return repository.addVehicle(
      make: make,
      model: model,
      color: color,
      licensePlate: licensePlate,
      year: year,
      imageUrl: imageUrl,
    );
  }
}
