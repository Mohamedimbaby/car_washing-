import 'package:equatable/equatable.dart';

class BookingStatsEntity extends Equatable {
  final int totalBookings;
  final int pendingBookings;
  final int confirmedBookings;
  final int completedBookings;
  final int cancelledBookings;
  final double totalRevenue;
  final double todayRevenue;
  final double monthRevenue;

  const BookingStatsEntity({
    required this.totalBookings,
    required this.pendingBookings,
    required this.confirmedBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.totalRevenue,
    required this.todayRevenue,
    required this.monthRevenue,
  });

  @override
  List<Object?> get props => [
        totalBookings,
        pendingBookings,
        confirmedBookings,
        completedBookings,
        cancelledBookings,
        totalRevenue,
        todayRevenue,
        monthRevenue,
      ];
}
