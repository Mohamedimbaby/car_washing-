import '../../../../core/utils/typedef.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository repository;

  CreateBookingUseCase(this.repository);

  ResultFuture<BookingEntity> call({
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
  }) {
    return repository.createBooking(
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
  }
}
