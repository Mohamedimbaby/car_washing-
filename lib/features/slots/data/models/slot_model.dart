import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/slot_entity.dart';

class SlotModel extends SlotEntity {
  const SlotModel({
    required super.id,
    required super.providerId,
    required super.appId,
    required super.date,
    required super.slots,
    required super.createdAt,
  });

  factory SlotModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    final slotsData = data['slots'] as List<dynamic>? ?? [];
    final slots = slotsData.map((slot) {
      return TimeSlotItem(
        time: slot['time'] ?? '',
        capacity: slot['capacity'] ?? 0,
        booked: slot['booked'] ?? 0,
      );
    }).toList();

    return SlotModel(
      id: doc.id,
      providerId: data['providerId'] ?? '',
      appId: data['appId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      slots: slots,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory SlotModel.fromEntity(SlotEntity entity) {
    return SlotModel(
      id: entity.id,
      providerId: entity.providerId,
      appId: entity.appId,
      date: entity.date,
      slots: entity.slots,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'providerId': providerId,
      'appId': appId,
      'date': Timestamp.fromDate(
        DateTime(date.year, date.month, date.day), // Store only date part
      ),
      'slots': slots.map((slot) {
        return {
          'time': slot.time,
          'capacity': slot.capacity,
          'booked': slot.booked,
        };
      }).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
