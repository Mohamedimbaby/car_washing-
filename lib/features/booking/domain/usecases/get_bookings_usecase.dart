import '../../../../core/utils/typedef.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetBookingsUseCase {
  final BookingRepository repository;

  GetBookingsUseCase(this.repository);

  ResultFuture<List<BookingEntity>> call() {
    return repository.getBookings();
  }
}
