import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/provider_repository.dart';
import 'provider_state.dart';

class ProviderCubit extends Cubit<ProviderState> {
  final ProviderRepository repository;

  ProviderCubit({required this.repository}) : super(ProviderInitial());

  Future<void> loadDashboard() async {
    emit(ProviderLoading());
    
    // Load stats and recent bookings in parallel
    final statsResult = await repository.getProviderStats();
    final bookingsResult = await repository.getRecentBookings(limit: 5);

    statsResult.fold(
      (failure) => emit(ProviderError(failure.message)),
      (stats) {
        bookingsResult.fold(
          (failure) => emit(ProviderError(failure.message)),
          (bookings) => emit(ProviderStatsLoaded(
            stats: stats,
            recentBookings: bookings,
          )),
        );
      },
    );
  }

  Future<void> confirmBooking(String bookingId) async {
    final result = await repository.confirmBooking(bookingId);
    result.fold(
      (failure) => emit(ProviderError(failure.message)),
      (_) {
        emit(const BookingActionSuccess('تم تأكيد الحجز / Booking confirmed'));
        loadDashboard(); // Reload stats
      },
    );
  }

  Future<void> completeBooking(String bookingId) async {
    final result = await repository.completeBooking(bookingId);
    result.fold(
      (failure) => emit(ProviderError(failure.message)),
      (_) {
        emit(const BookingActionSuccess('تم إنهاء الحجز / Booking completed'));
        loadDashboard(); // Reload stats
      },
    );
  }

  Future<void> reportBooking({
    required String bookingId,
    required List<String> reasons,
    required String details,
  }) async {
    final result = await repository.reportBooking(
      bookingId: bookingId,
      reasons: reasons,
      details: details,
    );
    result.fold(
      (failure) => emit(ProviderError(failure.message)),
      (_) {
        emit(const BookingActionSuccess('تم الإبلاغ عن الحجز / Booking reported'));
        loadDashboard(); // Reload stats
      },
    );
  }

  Future<void> loadProviderStats() async {
    await loadDashboard();
  }

  Future<void> loadProviderBookings() async {
    emit(ProviderLoading());
    final result = await repository.getRecentBookings(limit: 100); // Get more for filtering
    result.fold(
      (failure) => emit(ProviderError(failure.message)),
      (bookings) => emit(ProviderBookingsLoaded(bookings)),
    );
  }

  Future<void> loadCustomers() async {
    emit(ProviderLoading());
    final result = await repository.getCustomers();
    result.fold(
      (failure) => emit(ProviderError(failure.message)),
      (customers) => emit(ProviderCustomersLoaded(customers)),
    );
  }

  Future<void> loadCustomerBookings(String userId) async {
    emit(ProviderLoading());
    final result = await repository.getCustomerBookings(userId);
    result.fold(
      (failure) => emit(ProviderError(failure.message)),
      (bookings) => emit(CustomerBookingsLoaded(bookings)),
    );
  }
}
