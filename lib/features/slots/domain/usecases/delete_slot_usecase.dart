import '../../../../core/utils/typedef.dart';
import '../repositories/slot_repository.dart';

class DeleteSlotUseCase {
  final SlotRepository repository;

  DeleteSlotUseCase(this.repository);

  ResultVoid call(String slotId) {
    return repository.deleteSlot(slotId);
  }
}
