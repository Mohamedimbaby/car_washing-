import '../../../../core/utils/typedef.dart';
import '../entities/addon_entity.dart';
import '../repositories/booking_repository.dart';

class GetAddonsUseCase {
  final BookingRepository repository;

  GetAddonsUseCase(this.repository);

  ResultFuture<List<AddonEntity>> call() {
    return repository.getAddons();
  }
}
