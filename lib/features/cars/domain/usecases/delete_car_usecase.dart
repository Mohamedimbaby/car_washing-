import '../../../../core/utils/typedef.dart';
import '../repositories/car_repository.dart';

class DeleteCarUseCase {
  final CarRepository repository;

  DeleteCarUseCase(this.repository);

  ResultVoid call(String carId) {
    return repository.deleteCar(carId);
  }
}
