import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? profilePhoto;
  final int totalBookings;
  final double totalRevenue;
  final DateTime lastBookingDate;

  const CustomerEntity({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.profilePhoto,
    required this.totalBookings,
    required this.totalRevenue,
    required this.lastBookingDate,
  });

  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        phone,
        profilePhoto,
        totalBookings,
        totalRevenue,
        lastBookingDate,
      ];
}
