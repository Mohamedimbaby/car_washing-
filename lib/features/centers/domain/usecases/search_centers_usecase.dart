import '../../../../core/utils/typedef.dart';
import '../entities/center_entity.dart';
import '../repositories/center_repository.dart';

class SearchCentersUseCase {
  final CenterRepository repository;

  SearchCentersUseCase(this.repository);

  ResultFuture<List<CenterEntity>> call({
    required String query,
    double? latitude,
    double? longitude,
  }) {
    return repository.searchCenters(
      query: query,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
