import '../../../../core/utils/typedef.dart';
import '../entities/slot_entity.dart';

abstract class SlotRepository {
  /// Get all slots for current provider
  ResultFuture<List<SlotEntity>> getSlots({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get slot by date
  ResultFuture<SlotEntity?> getSlotByDate(DateTime date);

  /// Add new slot for a specific date
  ResultFuture<SlotEntity> addSlot({
    required DateTime date,
    required List<TimeSlotItem> slots,
  });

  /// Update existing slot
  ResultFuture<SlotEntity> updateSlot({
    required String slotId,
    required List<TimeSlotItem> slots,
  });

  /// Delete slot
  ResultVoid deleteSlot(String slotId);

  /// Add slots in bulk (for weekly/monthly creation)
  ResultFuture<List<SlotEntity>> addBulkSlots({
    required DateTime startDate,
    required DateTime endDate,
    required List<TimeSlotItem> slotTemplate,
    List<int>? daysOfWeek, // 1-7 (Monday-Sunday)
  });

  /// Check availability for booking (with transaction)
  ResultFuture<bool> checkAndReserveSlot({
    required DateTime date,
    required String timeSlot,
  });
}
