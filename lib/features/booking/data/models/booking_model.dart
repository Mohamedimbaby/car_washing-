import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.vehicleId,
    required super.centerId,
    super.branchId,
    required super.serviceType,
    required super.packageId,
    required super.addonIds,
    required super.scheduledDate,
    super.timeSlot,
    required super.status,
    required super.totalPrice,
    super.specialInstructions,
    super.location,
    required super.createdAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
      centerId: data['centerId'] ?? '',
      branchId: data['branchId'],
      serviceType: _parseServiceType(data['serviceType']),
      packageId: data['packageId'] ?? '',
      addonIds: List<String>.from(data['addonIds'] ?? []),
      scheduledDate: (data['scheduledDate'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'],
      status: _parseBookingStatus(data['status']),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      specialInstructions: data['specialInstructions'],
      location: data['location'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'vehicleId': vehicleId,
      'centerId': centerId,
      'branchId': branchId,
      'serviceType': serviceType.toString().split('.').last,
      'packageId': packageId,
      'addonIds': addonIds,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'timeSlot': timeSlot,
      'status': status.toString().split('.').last,
      'totalPrice': totalPrice,
      'specialInstructions': specialInstructions,
      'location': location,
      'createdAt':createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  static ServiceType _parseServiceType(String? type) {
    switch (type) {
      case 'inCenter':
        return ServiceType.inCenter;
      case 'onLocation':
        return ServiceType.onLocation;
      default:
        return ServiceType.inCenter;
    }
  }

  static BookingStatus _parseBookingStatus(String? status) {
    switch (status) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'inProgress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}
