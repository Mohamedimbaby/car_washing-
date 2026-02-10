import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/slot_entity.dart';
import '../../domain/repositories/slot_repository.dart';
import '../models/slot_model.dart';

class SlotRepositoryImpl implements SlotRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  SlotRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _currentProviderId => firebaseAuth.currentUser!.uid;
  String get _appId => AppConfig.appId;
  CollectionReference get _slotsCollection =>
      firestore.collection(AppConfig.collectionPath('slots'));

  @override
  ResultFuture<List<SlotEntity>> getSlots({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _slotsCollection
          .where('providerId', isEqualTo: _currentProviderId)
          .where('appId', isEqualTo: _appId)
          .orderBy('date', descending: false);

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(DateTime(startDate.year, startDate.month, startDate.day)));
      }

      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo:
                Timestamp.fromDate(DateTime(endDate.year, endDate.month, endDate.day)));
      }

      final snapshot = await query.get();
      final slots = snapshot.docs.map((doc) => SlotModel.fromFirestore(doc)).toList();

      return Right(slots);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<SlotEntity?> getSlotByDate(DateTime date) async {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final snapshot = await _slotsCollection
          .where('providerId', isEqualTo: _currentProviderId)
          .where('appId', isEqualTo: _appId)
          .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return const Right(null);
      }

      final slot = SlotModel.fromFirestore(snapshot.docs.first);
      return Right(slot);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<SlotEntity> addSlot({
    required DateTime date,
    required List<TimeSlotItem> slots,
  }) async {
    try {
      // Check if slot already exists for this date
      final existingSlotResult = await getSlotByDate(date);
      
      return existingSlotResult.fold(
        (failure) => Left(failure),
        (existingSlot) async {
          if (existingSlot != null) {
            return const Left(ServerFailure('Slot already exists for this date'));
          }

          final dateOnly = DateTime(date.year, date.month, date.day);
          final docRef = _slotsCollection.doc();
          
          final slotData = SlotModel(
            id: docRef.id,
            providerId: _currentProviderId,
            appId: _appId,
            date: dateOnly,
            slots: slots,
            createdAt: DateTime.now(),
          ).toFirestore();

          await docRef.set(slotData);

          final slot = SlotEntity(
            id: docRef.id,
            providerId: _currentProviderId,
            appId: _appId,
            date: dateOnly,
            slots: slots,
            createdAt: DateTime.now(),
          );

          return Right(slot);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<SlotEntity> updateSlot({
    required String slotId,
    required List<TimeSlotItem> slots,
  }) async {
    try {
      await _slotsCollection.doc(slotId).update({
        'slots': slots.map((slot) {
          return {
            'time': slot.time,
            'capacity': slot.capacity,
            'booked': slot.booked,
          };
        }).toList(),
      });

      final doc = await _slotsCollection.doc(slotId).get();
      final slot = SlotModel.fromFirestore(doc);

      return Right(slot);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid deleteSlot(String slotId) async {
    try {
      await _slotsCollection.doc(slotId).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<SlotEntity>> addBulkSlots({
    required DateTime startDate,
    required DateTime endDate,
    required List<TimeSlotItem> slotTemplate,
    List<int>? daysOfWeek,
  }) async {
    try {
      final createdSlots = <SlotEntity>[];
      final currentDate = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);

      // Use batch for better performance
      final batch = firestore.batch();
      
      DateTime date = currentDate;
      while (date.isBefore(end) || date.isAtSameMomentAs(end)) {
        // Check if we should create slot for this day of week
        if (daysOfWeek == null || daysOfWeek.contains(date.weekday)) {
          // Check if slot doesn't already exist
          final existingSlotResult = await getSlotByDate(date);
          final hasExisting = existingSlotResult.fold(
            (_) => false,
            (slot) => slot != null,
          );

          if (!hasExisting) {
            final docRef = _slotsCollection.doc();
            final slotData = SlotModel(
              id: docRef.id,
              providerId: _currentProviderId,
              appId: _appId,
              date: date,
              slots: slotTemplate,
              createdAt: DateTime.now(),
            ).toFirestore();

            batch.set(docRef, slotData);

            createdSlots.add(SlotEntity(
              id: docRef.id,
              providerId: _currentProviderId,
              appId: _appId,
              date: date,
              slots: slotTemplate,
              createdAt: DateTime.now(),
            ));
          }
        }

        date = date.add(const Duration(days: 1));
      }

      await batch.commit();
      return Right(createdSlots);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<bool> checkAndReserveSlot({
    required DateTime date,
    required String timeSlot,
  }) async {
    try {
      // First, find the slot document
      final dateOnly = DateTime(date.year, date.month, date.day);
      final querySnapshot = await _slotsCollection
          .where('providerId', isEqualTo: _currentProviderId)
          .where('appId', isEqualTo: _appId)
          .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Right(false);
      }

      final slotDoc = querySnapshot.docs.first;
      final slot = SlotModel.fromFirestore(slotDoc);

      // Find the time slot
      final slotIndex = slot.slots.indexWhere((s) => s.time == timeSlot);
      if (slotIndex == -1) {
        return const Right(false);
      }

      final timeSlotItem = slot.slots[slotIndex];
      if (timeSlotItem.isFull) {
        return const Right(false); // Already full
      }

      // Use transaction to update
      return await firestore.runTransaction((transaction) async {
        final docRef = _slotsCollection.doc(slotDoc.id);
        
        // Increment booked count
        final updatedSlots = List<TimeSlotItem>.from(slot.slots);
        updatedSlots[slotIndex] = timeSlotItem.copyWith(
          booked: timeSlotItem.booked + 1,
        );

        transaction.update(docRef, {
          'slots': updatedSlots.map((s) {
            return {
              'time': s.time,
              'capacity': s.capacity,
              'booked': s.booked,
            };
          }).toList(),
        });

        return const Right(true);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
