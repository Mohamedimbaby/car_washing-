import 'package:equatable/equatable.dart';

enum ServiceType { inCenter, onLocation }
enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

class BookingEntity extends Equatable {
  final String id;
  final String userId;
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
  final String? specialInstructions;
  final String? location;
  final DateTime? createdAt;

  const BookingEntity({
    required this.id,
    required this.userId,
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
    this.specialInstructions,
    this.location,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
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
        specialInstructions,
        location,
        createdAt,
      ];
}
