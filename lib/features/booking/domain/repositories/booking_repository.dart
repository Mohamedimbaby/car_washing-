import '../../../../core/utils/typedef.dart';
import '../entities/booking_entity.dart';
import '../entities/service_package_entity.dart';
import '../entities/addon_entity.dart';
import '../entities/time_slot_entity.dart';

abstract class BookingRepository {
  ResultFuture<List<ServicePackageEntity>> getServicePackages(
    ServiceType serviceType,
  );

  ResultFuture<List<AddonEntity>> getAddons();

  ResultFuture<List<TimeSlotEntity>> getAvailableTimeSlots({
    required String centerId,
    required DateTime date,
  });

  ResultFuture<BookingEntity> createBooking({
    required String vehicleId,
    required String providerId,
    required String centerId,
    String? branchId,
    required ServiceType serviceType,
    required String packageId,
    required List<String> addonIds,
    required DateTime scheduledDate,
    String? timeSlot,
    String? specialInstructions,
    String? location,
  });

  ResultFuture<List<BookingEntity>> getBookings();

  ResultFuture<BookingEntity> getBookingById(String id);

  ResultVoid cancelBooking(String id);
}
