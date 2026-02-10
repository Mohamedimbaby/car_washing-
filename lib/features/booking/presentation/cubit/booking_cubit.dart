import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/usecases/get_service_packages_usecase.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import '../../domain/usecases/get_bookings_usecase.dart';
import '../../domain/usecases/get_addons_usecase.dart';
import '../../domain/usecases/get_time_slots_usecase.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final GetServicePackagesUseCase getServicePackagesUseCase;
  final CreateBookingUseCase createBookingUseCase;
  final GetBookingsUseCase getBookingsUseCase;
  final GetAddonsUseCase getAddonsUseCase;
  final GetTimeSlotsUseCase getTimeSlotsUseCase;

  BookingCubit({
    required this.getServicePackagesUseCase,
    required this.createBookingUseCase,
    required this.getBookingsUseCase,
    required this.getAddonsUseCase,
    required this.getTimeSlotsUseCase,
  }) : super(BookingInitial());

  Future<void> loadServicePackages(ServiceType serviceType) async {
    emit(BookingLoading());
    final result = await getServicePackagesUseCase(serviceType);
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (packages) => emit(ServicePackagesLoaded(packages)),
    );
  }

  Future<void> createBooking({
    required String vehicleId,
    required String centerId,
    String? branchId,
    required ServiceType serviceType,
    required String packageId,
    required List<String> addonIds,
    required DateTime scheduledDate,
    String? timeSlot,
    String? specialInstructions,
    String? location,
  }) async {
    emit(BookingLoading());
    final result = await createBookingUseCase(
      vehicleId: vehicleId,
      centerId: centerId,
      branchId: branchId,
      serviceType: serviceType,
      packageId: packageId,
      addonIds: addonIds,
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      specialInstructions: specialInstructions,
      location: location,
    );
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (booking) => emit(BookingCreated(booking)),
    );
  }

  Future<void> loadBookings() async {
    emit(BookingLoading());
    final result = await getBookingsUseCase();
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (bookings) => emit(BookingsLoaded(bookings)),
    );
  }

  Future<void> loadAddons() async {
    emit(BookingLoading());
    final result = await getAddonsUseCase();
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (addons) => emit(AddonsLoaded(addons)),
    );
  }

  Future<void> loadTimeSlots({
    required String centerId,
    required DateTime date,
  }) async {
    emit(BookingLoading());
    final result = await getTimeSlotsUseCase(
      centerId: centerId,
      date: date,
    );
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (timeSlots) => emit(TimeSlotsLoaded(timeSlots)),
    );
  }
}
