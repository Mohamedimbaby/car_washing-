import 'package:equatable/equatable.dart';
import '../../domain/entities/schedule_config_entity.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleConfigLoaded extends ScheduleState {
  final ScheduleConfigEntity? config;

  const ScheduleConfigLoaded(this.config);

  @override
  List<Object?> get props => [config];
}

class ScheduleSaved extends ScheduleState {
  final String message;

  const ScheduleSaved(this.message);

  @override
  List<Object?> get props => [message];
}

class SlotsGenerated extends ScheduleState {
  final String message;
  final int slotsCount;

  const SlotsGenerated(this.message, this.slotsCount);

  @override
  List<Object?> get props => [message, slotsCount];
}

class ScheduleGenerating extends ScheduleState {
  final double progress; // 0.0 to 1.0

  const ScheduleGenerating(this.progress);

  @override
  List<Object?> get props => [progress];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}
