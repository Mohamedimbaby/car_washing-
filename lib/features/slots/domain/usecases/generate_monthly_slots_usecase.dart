import '../../../../core/utils/typedef.dart';
import '../repositories/schedule_repository.dart';

class GenerateMonthlySlotsUseCase {
  final ScheduleRepository repository;

  GenerateMonthlySlotsUseCase(this.repository);

  ResultVoid call({
    required String providerId,
    required DateTime month,
  }) {
    return repository.generateMonthlySlots(
      providerId: providerId,
      month: month,
    );
  }
}
