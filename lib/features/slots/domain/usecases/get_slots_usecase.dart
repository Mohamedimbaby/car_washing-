import '../../../../core/utils/typedef.dart';
import '../entities/slot_entity.dart';
import '../repositories/slot_repository.dart';

class GetSlotsUseCase {
  final SlotRepository repository;

  GetSlotsUseCase(this.repository);

  ResultFuture<List<SlotEntity>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return repository.getSlots(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
