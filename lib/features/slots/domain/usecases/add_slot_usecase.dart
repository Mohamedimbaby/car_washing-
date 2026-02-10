import '../../../../core/utils/typedef.dart';
import '../entities/slot_entity.dart';
import '../repositories/slot_repository.dart';

class AddSlotUseCase {
  final SlotRepository repository;

  AddSlotUseCase(this.repository);

  ResultFuture<SlotEntity> call({
    required DateTime date,
    required List<TimeSlotItem> slots,
  }) {
    return repository.addSlot(date: date, slots: slots);
  }
}
