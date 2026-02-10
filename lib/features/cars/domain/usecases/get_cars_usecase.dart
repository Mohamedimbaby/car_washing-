import '../../../../core/utils/typedef.dart';
import '../entities/car_entity.dart';
import '../repositories/car_repository.dart';

class GetCarsUseCase {
  final CarRepository repository;

  GetCarsUseCase(this.repository);

  ResultFuture<List<CarEntity>> call() {
    return repository.getCars();
  }
}
