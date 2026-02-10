import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/typedef.dart';
import '../../../booking/domain/entities/booking_entity.dart';
import '../entities/provider_stats_entity.dart';
import '../entities/customer_entity.dart';

abstract class ProviderRepository {
  /// Get provider dashboard statistics
  ResultFuture<ProviderStatsEntity> getProviderStats();

  /// Get bookings stream for real-time updates
  Stream<List<BookingEntity>> getBookingsStream({String? status});

  /// Get recent bookings (last N)
  ResultFuture<List<BookingEntity>> getRecentBookings({int limit = 5});

  /// Confirm booking
  ResultVoid confirmBooking(String bookingId);

  /// Mark booking as completed
  ResultVoid completeBooking(String bookingId);

  /// Report booking
  ResultVoid reportBooking({
    required String bookingId,
    required List<String> reasons,
    required String details,
  });

  /// Get all customers who have booked with this provider
  ResultFuture<List<CustomerEntity>> getCustomers();

  /// Get customer bookings history
  ResultFuture<List<BookingEntity>> getCustomerBookings(String userId);
}
