import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/schedule_config_entity.dart';

class ScheduleConfigModel extends ScheduleConfigEntity {
  const ScheduleConfigModel({
    required super.id,
    required super.providerId,
    required super.appId,
    required super.washingCapacity,
    required super.workingStartTime,
    required super.workingEndTime,
    required super.offDays,
    required super.dateRangeStart,
    required super.dateRangeEnd,
    super.slotDurationMinutes = 30,
    required super.createdAt,
    super.lastGenerated,
    super.updatedAt,
  });

  factory ScheduleConfigModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse working hours
    final startTimeParts = (data['workingStartTime'] as String).split(':');
    final endTimeParts = (data['workingEndTime'] as String).split(':');

    return ScheduleConfigModel(
      id: doc.id,
      providerId: data['providerId'] as String,
      appId: data['appId'] as String,
      washingCapacity: data['washingCapacity'] as int,
      workingStartTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      workingEndTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      offDays: List<int>.from(data['offDays'] ?? []),
      dateRangeStart: (data['dateRangeStart'] as Timestamp).toDate(),
      dateRangeEnd: (data['dateRangeEnd'] as Timestamp).toDate(),
      slotDurationMinutes: data['slotDurationMinutes'] as int? ?? 30,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastGenerated: data['lastGenerated'] != null
          ? (data['lastGenerated'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'providerId': providerId,
      'appId': appId,
      'washingCapacity': washingCapacity,
      'workingStartTime':
          '${workingStartTime.hour.toString().padLeft(2, '0')}:${workingStartTime.minute.toString().padLeft(2, '0')}',
      'workingEndTime':
          '${workingEndTime.hour.toString().padLeft(2, '0')}:${workingEndTime.minute.toString().padLeft(2, '0')}',
      'offDays': offDays,
      'dateRangeStart': Timestamp.fromDate(dateRangeStart),
      'dateRangeEnd': Timestamp.fromDate(dateRangeEnd),
      'slotDurationMinutes': slotDurationMinutes,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastGenerated':
          lastGenerated != null ? Timestamp.fromDate(lastGenerated!) : null,
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
