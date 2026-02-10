import '../../../../core/utils/typedef.dart';
import '../entities/schedule_config_entity.dart';
import '../repositories/schedule_repository.dart';

class GetScheduleConfigUseCase {
  final ScheduleRepository repository;

  GetScheduleConfigUseCase(this.repository);

  ResultFuture<ScheduleConfigEntity?> call(String providerId) {
    return repository.getScheduleConfig(providerId);
  }
}
