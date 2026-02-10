import '../../../../core/utils/typedef.dart';
import '../entities/slot_entity.dart';
import '../repositories/slot_repository.dart';

class UpdateSlotUseCase {
  final SlotRepository repository;

  UpdateSlotUseCase(this.repository);

  ResultFuture<SlotEntity> call({
    required String slotId,
    required List<TimeSlotItem> slots,
  }) {
    return repository.updateSlot(slotId: slotId, slots: slots);
  }
}
