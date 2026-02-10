import 'package:equatable/equatable.dart';

enum StaffRole { manager, washer, mobileServiceTech }

class StaffEntity extends Equatable {
  final String id;
  final String centerId;
  final String? branchId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final StaffRole role;
  final bool isActive;
  final DateTime createdAt;

  const StaffEntity({
    required this.id,
    required this.centerId,
    this.branchId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        centerId,
        branchId,
        fullName,
        email,
        phoneNumber,
        role,
        isActive,
        createdAt,
      ];
}
