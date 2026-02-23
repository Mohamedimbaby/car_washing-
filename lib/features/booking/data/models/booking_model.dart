import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.providerId,
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
    super.currency,
    super.specialInstructions,
    super.location,
    super.paymentStatus,
    super.confirmedAt,
    super.startedAt,
    super.completedAt,
    super.cancelledAt,
    super.cancelReason,
    required super.createdAt,
    super.updatedAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      providerId: data['providerId'] ?? '',
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
      currency: data['currency'] ?? 'EGP',
      specialInstructions: data['specialInstructions'],
      location: data['location'],
      paymentStatus: data['paymentStatus'],
      confirmedAt: _parseTimestamp(data['confirmedAt']),
      startedAt: _parseTimestamp(data['startedAt']),
      completedAt: _parseTimestamp(data['completedAt']),
      cancelledAt: _parseTimestamp(data['cancelledAt']),
      cancelReason: data['cancelReason'],
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'providerId': providerId,
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
      'currency': currency,
      'specialInstructions': specialInstructions,
      'location': location,
      'paymentStatus': paymentStatus,
      'confirmedAt': confirmedAt != null
          ? Timestamp.fromDate(confirmedAt!)
          : null,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'cancelledAt': cancelledAt != null
          ? Timestamp.fromDate(cancelledAt!)
          : null,
      'cancelReason': cancelReason,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
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
      case 'noShow':
        return BookingStatus.noShow;
      default:
        return BookingStatus.pending;
    }
  }
}
