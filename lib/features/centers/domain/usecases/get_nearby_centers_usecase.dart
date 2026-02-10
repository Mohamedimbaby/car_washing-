import '../../../../core/utils/typedef.dart';
import '../entities/center_entity.dart';
import '../repositories/center_repository.dart';

class GetNearbyCentersUseCase {
  final CenterRepository repository;

  GetNearbyCentersUseCase(this.repository);

  ResultFuture<List<CenterEntity>> call({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) {
    return repository.getNearbyCenters(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }
}
