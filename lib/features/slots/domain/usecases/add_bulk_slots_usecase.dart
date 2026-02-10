import '../../../../core/utils/typedef.dart';
import '../entities/slot_entity.dart';
import '../repositories/slot_repository.dart';

class AddBulkSlotsUseCase {
  final SlotRepository repository;

  AddBulkSlotsUseCase(this.repository);

  ResultFuture<List<SlotEntity>> call({
    required DateTime startDate,
    required DateTime endDate,
    required List<TimeSlotItem> slotTemplate,
    List<int>? daysOfWeek,
  }) {
    return repository.addBulkSlots(
      startDate: startDate,
      endDate: endDate,
      slotTemplate: slotTemplate,
      daysOfWeek: daysOfWeek,
    );
  }
}
