import 'package:equatable/equatable.dart';

class TimeSlotItem extends Equatable {
  final String time;
  final int capacity;
  final int booked;

  const TimeSlotItem({
    required this.time,
    required this.capacity,
    this.booked = 0,
  });

  int get available => capacity - booked;
  bool get isFull => booked >= capacity;

  TimeSlotItem copyWith({
    String? time,
    int? capacity,
    int? booked,
  }) {
    return TimeSlotItem(
      time: time ?? this.time,
      capacity: capacity ?? this.capacity,
      booked: booked ?? this.booked,
    );
  }

  @override
  List<Object?> get props => [time, capacity, booked];
}

class SlotEntity extends Equatable {
  final String id;
  final String providerId;
  final String appId;
  final DateTime date;
  final List<TimeSlotItem> slots;
  final DateTime createdAt;

  const SlotEntity({
    required this.id,
    required this.providerId,
    required this.appId,
    required this.date,
    required this.slots,
    required this.createdAt,
  });

  SlotEntity copyWith({
    String? id,
    String? providerId,
    String? appId,
    DateTime? date,
    List<TimeSlotItem>? slots,
    DateTime? createdAt,
  }) {
    return SlotEntity(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      appId: appId ?? this.appId,
      date: date ?? this.date,
      slots: slots ?? this.slots,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, providerId, appId, date, slots, createdAt];
}
