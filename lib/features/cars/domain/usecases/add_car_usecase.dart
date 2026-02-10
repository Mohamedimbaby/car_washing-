import 'dart:io';
import '../../../../core/utils/typedef.dart';
import '../entities/car_entity.dart';
import '../repositories/car_repository.dart';

class AddCarUseCase {
  final CarRepository repository;

  AddCarUseCase(this.repository);

  ResultFuture<CarEntity> call({
    required String plateNumber,
    required String brand,
    required String model,
    required String color,
    required int year,
    required File imageFile,
    bool isDefault = false,
  }) {
    return repository.addCar(
      plateNumber: plateNumber,
      brand: brand,
      model: model,
      color: color,
      year: year,
      imageFile: imageFile,
      isDefault: isDefault,
    );
  }
}
