import 'dart:io';
import '../../../../core/utils/typedef.dart';
import '../entities/car_entity.dart';
import '../repositories/car_repository.dart';

class UpdateCarUseCase {
  final CarRepository repository;

  UpdateCarUseCase(this.repository);

  ResultFuture<CarEntity> call({
    required String carId,
    String? plateNumber,
    String? brand,
    String? model,
    String? color,
    int? year,
    File? imageFile,
    bool? isDefault,
  }) {
    return repository.updateCar(
      carId: carId,
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
