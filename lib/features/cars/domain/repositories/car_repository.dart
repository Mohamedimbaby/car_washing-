import 'dart:io';
import '../../../../core/utils/typedef.dart';
import '../entities/car_entity.dart';

abstract class CarRepository {
  /// Get all cars for current user
  ResultFuture<List<CarEntity>> getCars();

  /// Get car by ID
  ResultFuture<CarEntity> getCarById(String carId);

  /// Add new car
  ResultFuture<CarEntity> addCar({
    required String plateNumber,
    required String brand,
    required String model,
    required String color,
    required int year,
    required File imageFile,
    bool isDefault,
  });

  /// Update existing car
  ResultFuture<CarEntity> updateCar({
    required String carId,
    String? plateNumber,
    String? brand,
    String? model,
    String? color,
    int? year,
    File? imageFile,
    bool? isDefault,
  });

  /// Delete car
  ResultVoid deleteCar(String carId);

  /// Set car as default
  ResultVoid setDefaultCar(String carId);
}
