import 'package:equatable/equatable.dart';
import '../../../booking/domain/entities/booking_entity.dart';
import '../../domain/entities/provider_stats_entity.dart';
import '../../domain/entities/customer_entity.dart';

abstract class ProviderState extends Equatable {
  const ProviderState();

  @override
  List<Object?> get props => [];
}

class ProviderInitial extends ProviderState {}

class ProviderLoading extends ProviderState {}

class ProviderStatsLoaded extends ProviderState {
  final ProviderStatsEntity stats;
  final List<BookingEntity> recentBookings;

  const ProviderStatsLoaded({
    required this.stats,
    required this.recentBookings,
  });

  @override
  List<Object?> get props => [stats, recentBookings];
}

class ProviderBookingsLoaded extends ProviderState {
  final List<BookingEntity> bookings;

  const ProviderBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class ProviderCustomersLoaded extends ProviderState {
  final List<CustomerEntity> customers;

  const ProviderCustomersLoaded(this.customers);

  @override
  List<Object?> get props => [customers];
}

class CustomerBookingsLoaded extends ProviderState {
  final List<BookingEntity> bookings;

  const CustomerBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class BookingActionSuccess extends ProviderState {
  final String message;

  const BookingActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProviderError extends ProviderState {
  final String message;

  const ProviderError(this.message);

  @override
  List<Object?> get props => [message];
}
