import 'package:equatable/equatable.dart';

enum ServiceType { inCenter, onLocation }

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow,
}

class BookingEntity extends Equatable {
  final String id;
  final String userId;
  final String providerId;
  final String vehicleId;
  final String centerId;
  final String? branchId;
  final ServiceType serviceType;
  final String packageId;
  final List<String> addonIds;
  final DateTime scheduledDate;
  final String? timeSlot;
  final BookingStatus status;
  final double totalPrice;
  final String currency;
  final String? specialInstructions;
  final String? location;
  final String? paymentStatus;
  final DateTime? confirmedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.vehicleId,
    required this.centerId,
    this.branchId,
    required this.serviceType,
    required this.packageId,
    required this.addonIds,
    required this.scheduledDate,
    this.timeSlot,
    required this.status,
    required this.totalPrice,
    this.currency = 'EGP',
    this.specialInstructions,
    this.location,
    this.paymentStatus,
    this.confirmedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelReason,
    required this.createdAt,
    this.updatedAt,
  });

  BookingEntity copyWith({
    String? id,
    String? userId,
    String? providerId,
    String? vehicleId,
    String? centerId,
    String? branchId,
    ServiceType? serviceType,
    String? packageId,
    List<String>? addonIds,
    DateTime? scheduledDate,
    String? timeSlot,
    BookingStatus? status,
    double? totalPrice,
    String? currency,
    String? specialInstructions,
    String? location,
    String? paymentStatus,
    DateTime? confirmedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancelReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      vehicleId: vehicleId ?? this.vehicleId,
      centerId: centerId ?? this.centerId,
      branchId: branchId ?? this.branchId,
      serviceType: serviceType ?? this.serviceType,
      packageId: packageId ?? this.packageId,
      addonIds: addonIds ?? this.addonIds,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      location: location ?? this.location,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelReason: cancelReason ?? this.cancelReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    providerId,
    vehicleId,
    centerId,
    branchId,
    serviceType,
    packageId,
    addonIds,
    scheduledDate,
    timeSlot,
    status,
    totalPrice,
    currency,
    specialInstructions,
    location,
    paymentStatus,
    confirmedAt,
    startedAt,
    completedAt,
    cancelledAt,
    cancelReason,
    createdAt,
    updatedAt,
  ];
}
