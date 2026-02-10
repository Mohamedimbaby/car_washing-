import '../../../../core/utils/typedef.dart';
import '../entities/center_entity.dart';
import '../repositories/center_repository.dart';

class GetCenterByIdUseCase {
  final CenterRepository repository;

  GetCenterByIdUseCase(this.repository);

  ResultFuture<CenterEntity> call(String id) {
    return repository.getCenterById(id);
  }
}
