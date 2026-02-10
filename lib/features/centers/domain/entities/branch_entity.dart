import 'package:equatable/equatable.dart';

class BranchEntity extends Equatable {
  final String id;
  final String centerId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String operatingHours;
  final int availableBays;
  final double serviceAreaRadius;
  final bool isActive;

  const BranchEntity({
    required this.id,
    required this.centerId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.operatingHours,
    required this.availableBays,
    required this.serviceAreaRadius,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        centerId,
        name,
        address,
        latitude,
        longitude,
        phoneNumber,
        operatingHours,
        availableBays,
        serviceAreaRadius,
        isActive,
      ];
}
