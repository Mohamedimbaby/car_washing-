import 'package:equatable/equatable.dart';

class ProviderStatsEntity extends Equatable {
  final int pendingBookings;
  final int completedBookings;
  final double totalIncome;
  final int totalCustomers;
  final int activePackages;

  const ProviderStatsEntity({
    required this.pendingBookings,
    required this.completedBookings,
    required this.totalIncome,
    required this.totalCustomers,
    required this.activePackages,
  });

  @override
  List<Object?> get props => [
        pendingBookings,
        completedBookings,
        totalIncome,
        totalCustomers,
        activePackages,
      ];
}
