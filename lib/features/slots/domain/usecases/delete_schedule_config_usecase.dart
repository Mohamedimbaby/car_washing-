import '../../../../core/utils/typedef.dart';
import '../repositories/schedule_repository.dart';

class DeleteScheduleConfigUseCase {
  final ScheduleRepository repository;

  DeleteScheduleConfigUseCase(this.repository);

  ResultVoid call(String configId) {
    return repository.deleteScheduleConfig(configId);
  }
}
