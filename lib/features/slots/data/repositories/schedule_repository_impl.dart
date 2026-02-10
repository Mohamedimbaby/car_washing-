import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/schedule_config_entity.dart';
import '../../domain/entities/slot_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../models/schedule_config_model.dart';
import '../models/slot_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ScheduleRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _appId => AppConfig.appId;
  CollectionReference get _scheduleConfigsCollection =>
      firestore.collection(AppConfig.collectionPath('schedule_configs'));
  CollectionReference get _slotsCollection =>
      firestore.collection(AppConfig.collectionPath('slots'));

  @override
  ResultFuture<ScheduleConfigEntity?> getScheduleConfig(
      String providerId) async {
    try {
      final querySnapshot = await _scheduleConfigsCollection
          .where('providerId', isEqualTo: providerId)
          .where('appId', isEqualTo: _appId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Right(null);
      }

      final config = ScheduleConfigModel.fromFirestore(querySnapshot.docs.first);
      return Right(config);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid saveScheduleConfig(ScheduleConfigEntity config) async {
    try {
      final model = ScheduleConfigModel(
        id: config.id,
        providerId: config.providerId,
        appId: config.appId,
        washingCapacity: config.washingCapacity,
        workingStartTime: config.workingStartTime,
        workingEndTime: config.workingEndTime,
        offDays: config.offDays,
        dateRangeStart: config.dateRangeStart,
        dateRangeEnd: config.dateRangeEnd,
        slotDurationMinutes: config.slotDurationMinutes,
        createdAt: config.createdAt,
        lastGenerated: config.lastGenerated,
        updatedAt: DateTime.now(),
      );

      await _scheduleConfigsCollection.doc(config.id).set(model.toFirestore());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid generateMonthlySlots({
    required String providerId,
    required DateTime month, // Keep for backwards compatibility, but use config dates
  }) async {
    try {
      print('🔵 Starting slot generation for provider: $providerId');
      
      // Get schedule config
      final configResult = await getScheduleConfig(providerId);
      
      final ScheduleConfigEntity? config = configResult.fold(
        (failure) {
          print('❌ Failed to get config: ${failure.message}');
          return null;
        },
        (config) {
          print('✅ Config loaded: ${config?.id}');
          return config;
        },
      );

      if (config == null) {
        print('❌ No config found for provider: $providerId');
        return const Left(ServerFailure('Schedule configuration not found. Please save configuration first.'));
      }

      print('📅 Date range: ${config.dateRangeStart} to ${config.dateRangeEnd}');
      print('⏰ Working hours: ${config.workingStartTime} to ${config.workingEndTime}');
      print('🚫 Off days: ${config.offDays}');
      print('🚗 Capacity: ${config.washingCapacity}');
      print('⏱️ Slot duration: ${config.slotDurationMinutes} minutes');

      // Use date range from config
      final startDate = config.dateRangeStart;
      final endDate = config.dateRangeEnd;

      int slotsCreated = 0;
      int daysProcessed = 0;

      // Generate slots for each day in the range
      for (var date = startDate;
          date.isBefore(endDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        
        // Skip if this weekday is in offDays list
        if (config.offDays.contains(date.weekday)) {
          print('⏭️ Skipping ${date.toString().split(' ')[0]} (weekday ${date.weekday} is off day)');
          continue;
        }

        daysProcessed++;
        print('📝 Processing ${date.toString().split(' ')[0]} (weekday ${date.weekday})...');

        // Generate time slots for this working day
        final slots = _generateTimeSlotsForDay(
          startTime: config.workingStartTime,
          endTime: config.workingEndTime,
          slotDuration: config.slotDurationMinutes,
          capacity: config.washingCapacity,
        );

        print('   ➡️ Generated ${slots.length} time slots for this day');

        // Save slots to Firestore
        final slotId = '${config.providerId}_${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
        final slotEntity = SlotEntity(
          id: slotId,
          providerId: config.providerId,
          appId: config.appId,
          date: DateTime(date.year, date.month, date.day),
          slots: slots,
          createdAt: DateTime.now(),
        );

        final slotModel = SlotModel.fromEntity(slotEntity);
        final firestoreData = slotModel.toFirestore();
        
        print('   💾 Saving to Firestore with ID: $slotId');
        print('   📦 Collection path: ${_slotsCollection.path}');
        
        await _slotsCollection.doc(slotEntity.id).set(firestoreData);
        slotsCreated++;
        print('   ✅ Saved successfully!');
      }

      print('🎉 Total: $slotsCreated slot documents created for $daysProcessed working days');

      // Update lastGenerated in config
      print('🔄 Updating lastGenerated timestamp...');
      await _scheduleConfigsCollection.doc(config.id).update({
        'lastGenerated': Timestamp.fromDate(DateTime.now()),
      });
      print('✅ lastGenerated updated');

      return const Right(null);
    } catch (e, stackTrace) {
      print('❌ ERROR generating slots: $e');
      print('Stack trace: $stackTrace');
      return Left(ServerFailure('Failed to generate slots: $e'));
    }
  }

  List<TimeSlotItem> _generateTimeSlotsForDay({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int slotDuration, // 30 minutes by default
    required int capacity,
  }) {
    final List<TimeSlotItem> slots = [];

    int currentHour = startTime.hour;
    int currentMinute = startTime.minute;

    final endHour = endTime.hour;
    final endMinute = endTime.minute;

    // Generate slots at slotDuration intervals (default 30 min)
    while (currentHour < endHour ||
        (currentHour == endHour && currentMinute < endMinute)) {
      slots.add(TimeSlotItem(
        time:
            '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}',
        capacity: capacity,
        booked: 0,
      ));

      // Increment by slot duration
      currentMinute += slotDuration;
      if (currentMinute >= 60) {
        currentHour += currentMinute ~/ 60;
        currentMinute = currentMinute % 60;
      }
    }

    return slots;
  }

  @override
  ResultVoid deleteScheduleConfig(String configId) async {
    try {
      await _scheduleConfigsCollection.doc(configId).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
