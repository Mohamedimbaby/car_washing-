import 'package:equatable/equatable.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/service_package_entity.dart';
import '../../domain/entities/addon_entity.dart';
import '../../domain/entities/time_slot_entity.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class ServicePackagesLoaded extends BookingState {
  final List<ServicePackageEntity> packages;

  const ServicePackagesLoaded(this.packages);

  @override
  List<Object?> get props => [packages];
}

class AddonsLoaded extends BookingState {
  final List<AddonEntity> addons;

  const AddonsLoaded(this.addons);

  @override
  List<Object?> get props => [addons];
}

class TimeSlotsLoaded extends BookingState {
  final List<TimeSlotEntity> timeSlots;

  const TimeSlotsLoaded(this.timeSlots);

  @override
  List<Object?> get props => [timeSlots];
}

class BookingCreated extends BookingState {
  final BookingEntity booking;

  const BookingCreated(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingsLoaded extends BookingState {
  final List<BookingEntity> bookings;

  const BookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}
