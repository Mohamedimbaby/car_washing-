import '../../../../core/utils/typedef.dart';
import '../entities/vehicle_entity.dart';

abstract class VehicleRepository {
  ResultFuture<List<VehicleEntity>> getVehicles();
  
  ResultFuture<VehicleEntity> getVehicleById(String id);
  
  ResultFuture<VehicleEntity> addVehicle({
    required String make,
    required String model,
    required String color,
    required String licensePlate,
    required int year,
    String? imageUrl,
  });
  
  ResultVoid updateVehicle({
    required String id,
    String? make,
    String? model,
    String? color,
    String? licensePlate,
    int? year,
    String? imageUrl,
  });
  
  ResultVoid deleteVehicle(String id);
  
  ResultVoid setDefaultVehicle(String id);
}
