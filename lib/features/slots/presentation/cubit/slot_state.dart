import 'package:equatable/equatable.dart';
import '../../domain/entities/slot_entity.dart';

abstract class SlotState extends Equatable {
  const SlotState();

  @override
  List<Object?> get props => [];
}

class SlotInitial extends SlotState {}

class SlotLoading extends SlotState {}

class SlotsLoaded extends SlotState {
  final List<SlotEntity> slots;

  const SlotsLoaded(this.slots);

  @override
  List<Object?> get props => [slots];
}

class SlotAdded extends SlotState {
  final SlotEntity slot;

  const SlotAdded(this.slot);

  @override
  List<Object?> get props => [slot];
}

class BulkSlotsAdded extends SlotState {
  final List<SlotEntity> slots;

  const BulkSlotsAdded(this.slots);

  @override
  List<Object?> get props => [slots];
}

class SlotUpdated extends SlotState {
  final SlotEntity slot;

  const SlotUpdated(this.slot);

  @override
  List<Object?> get props => [slot];
}

class SlotDeleted extends SlotState {}

class SlotError extends SlotState {
  final String message;

  const SlotError(this.message);

  @override
  List<Object?> get props => [message];
}
