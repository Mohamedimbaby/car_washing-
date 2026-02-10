import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ScheduleConfigEntity extends Equatable {
  final String id;
  final String providerId;
  final String appId;
  final int washingCapacity; // How many cars can be washed at the same time
  
  // Simplified fields - single working hours for all days
  final TimeOfDay workingStartTime; // e.g., 8:00 AM
  final TimeOfDay workingEndTime; // e.g., 10:00 PM
  final List<int> offDays; // e.g., [5, 7] = Friday, Sunday off (1=Mon, 7=Sun)
  final DateTime dateRangeStart; // e.g., Feb 10, 2026
  final DateTime dateRangeEnd; // e.g., Mar 10, 2026
  final int slotDurationMinutes; // Default: 30 minutes
  
  final DateTime createdAt;
  final DateTime? lastGenerated; // Track last generation date
  final DateTime? updatedAt;

  const ScheduleConfigEntity({
    required this.id,
    required this.providerId,
    required this.appId,
    required this.washingCapacity,
    required this.workingStartTime,
    required this.workingEndTime,
    required this.offDays,
    required this.dateRangeStart,
    required this.dateRangeEnd,
    this.slotDurationMinutes = 30,
    required this.createdAt,
    this.lastGenerated,
    this.updatedAt,
  });

  ScheduleConfigEntity copyWith({
    String? id,
    String? providerId,
    String? appId,
    int? washingCapacity,
    TimeOfDay? workingStartTime,
    TimeOfDay? workingEndTime,
    List<int>? offDays,
    DateTime? dateRangeStart,
    DateTime? dateRangeEnd,
    int? slotDurationMinutes,
    DateTime? createdAt,
    DateTime? lastGenerated,
    DateTime? updatedAt,
  }) {
    return ScheduleConfigEntity(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      appId: appId ?? this.appId,
      washingCapacity: washingCapacity ?? this.washingCapacity,
      workingStartTime: workingStartTime ?? this.workingStartTime,
      workingEndTime: workingEndTime ?? this.workingEndTime,
      offDays: offDays ?? this.offDays,
      dateRangeStart: dateRangeStart ?? this.dateRangeStart,
      dateRangeEnd: dateRangeEnd ?? this.dateRangeEnd,
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      createdAt: createdAt ?? this.createdAt,
      lastGenerated: lastGenerated ?? this.lastGenerated,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if a specific date is a working day (not in offDays list)
  bool isWorkingDay(DateTime date) {
    return !offDays.contains(date.weekday);
  }

  // Calculate total working days in the date range
  int calculateTotalWorkingDays() {
    int count = 0;
    for (var date = dateRangeStart;
        date.isBefore(dateRangeEnd.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      if (isWorkingDay(date)) {
        count++;
      }
    }
    return count;
  }

  // Calculate slots per day based on working hours and slot duration
  int calculateSlotsPerDay() {
    final totalMinutes = (workingEndTime.hour * 60 + workingEndTime.minute) -
        (workingStartTime.hour * 60 + workingStartTime.minute);
    return (totalMinutes / slotDurationMinutes).floor();
  }

  // Calculate total slots to be generated
  int calculateTotalSlots() {
    return calculateTotalWorkingDays() * calculateSlotsPerDay();
  }

  @override
  List<Object?> get props => [
        id,
        providerId,
        appId,
        washingCapacity,
        workingStartTime,
        workingEndTime,
        offDays,
        dateRangeStart,
        dateRangeEnd,
        slotDurationMinutes,
        createdAt,
        lastGenerated,
        updatedAt,
      ];
}
