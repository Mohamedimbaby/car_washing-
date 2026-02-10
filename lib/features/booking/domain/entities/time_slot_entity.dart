import 'package:equatable/equatable.dart';

class TimeSlotEntity extends Equatable {
  final String id;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final int availableSlots;

  const TimeSlotEntity({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.availableSlots,
  });

  @override
  List<Object?> get props => [
        id,
        startTime,
        endTime,
        isAvailable,
        availableSlots,
      ];
}
