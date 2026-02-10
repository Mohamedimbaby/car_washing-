import '../../../../core/utils/typedef.dart';
import '../entities/time_slot_entity.dart';
import '../repositories/booking_repository.dart';

class GetTimeSlotsUseCase {
  final BookingRepository repository;

  GetTimeSlotsUseCase(this.repository);

  ResultFuture<List<TimeSlotEntity>> call({
    required String centerId,
    required DateTime date,
  }) {
    return repository.getAvailableTimeSlots(
      centerId: centerId,
      date: date,
    );
  }
}
