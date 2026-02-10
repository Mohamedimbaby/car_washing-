import '../../../../core/utils/typedef.dart';
import '../entities/schedule_config_entity.dart';
import '../repositories/schedule_repository.dart';

class SaveScheduleConfigUseCase {
  final ScheduleRepository repository;

  SaveScheduleConfigUseCase(this.repository);

  ResultVoid call(ScheduleConfigEntity config) {
    return repository.saveScheduleConfig(config);
  }
}
