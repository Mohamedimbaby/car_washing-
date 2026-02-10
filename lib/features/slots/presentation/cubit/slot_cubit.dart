import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/slot_entity.dart';
import '../../domain/usecases/get_slots_usecase.dart';
import '../../domain/usecases/add_slot_usecase.dart';
import '../../domain/usecases/update_slot_usecase.dart';
import '../../domain/usecases/delete_slot_usecase.dart';
import '../../domain/usecases/add_bulk_slots_usecase.dart';
import 'slot_state.dart';

class SlotCubit extends Cubit<SlotState> {
  final GetSlotsUseCase getSlotsUseCase;
  final AddSlotUseCase addSlotUseCase;
  final UpdateSlotUseCase updateSlotUseCase;
  final DeleteSlotUseCase deleteSlotUseCase;
  final AddBulkSlotsUseCase addBulkSlotsUseCase;

  SlotCubit({
    required this.getSlotsUseCase,
    required this.addSlotUseCase,
    required this.updateSlotUseCase,
    required this.deleteSlotUseCase,
    required this.addBulkSlotsUseCase,
  }) : super(SlotInitial());

  Future<void> loadSlots({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(SlotLoading());
    final result = await getSlotsUseCase(
      startDate: startDate,
      endDate: endDate,
    );
    result.fold(
      (failure) => emit(SlotError(failure.message)),
      (slots) => emit(SlotsLoaded(slots)),
    );
  }

  Future<void> addSlot({
    required DateTime date,
    required List<TimeSlotItem> slots,
  }) async {
    emit(SlotLoading());
    final result = await addSlotUseCase(date: date, slots: slots);
    result.fold(
      (failure) => emit(SlotError(failure.message)),
      (slot) {
        emit(SlotAdded(slot));
        loadSlots(); // Refresh list
      },
    );
  }

  Future<void> addBulkSlots({
    required DateTime startDate,
    required DateTime endDate,
    required List<TimeSlotItem> slotTemplate,
    List<int>? daysOfWeek,
  }) async {
    emit(SlotLoading());
    final result = await addBulkSlotsUseCase(
      startDate: startDate,
      endDate: endDate,
      slotTemplate: slotTemplate,
      daysOfWeek: daysOfWeek,
    );
    result.fold(
      (failure) => emit(SlotError(failure.message)),
      (slots) {
        emit(BulkSlotsAdded(slots));
        loadSlots(); // Refresh list
      },
    );
  }

  Future<void> updateSlot({
    required String slotId,
    required List<TimeSlotItem> slots,
  }) async {
    emit(SlotLoading());
    final result = await updateSlotUseCase(slotId: slotId, slots: slots);
    result.fold(
      (failure) => emit(SlotError(failure.message)),
      (slot) {
        emit(SlotUpdated(slot));
        loadSlots(); // Refresh list
      },
    );
  }

  Future<void> deleteSlot(String slotId) async {
    emit(SlotLoading());
    final result = await deleteSlotUseCase(slotId);
    result.fold(
      (failure) => emit(SlotError(failure.message)),
      (_) {
        emit(SlotDeleted());
        loadSlots(); // Refresh list
      },
    );
  }
}
