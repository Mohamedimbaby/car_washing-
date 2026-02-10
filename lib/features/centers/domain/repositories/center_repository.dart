import '../../../../core/utils/typedef.dart';
import '../entities/center_entity.dart';
import '../entities/branch_entity.dart';

abstract class CenterRepository {
  ResultFuture<List<CenterEntity>> getNearbyCenters({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  });

  ResultFuture<List<CenterEntity>> searchCenters({
    required String query,
    double? latitude,
    double? longitude,
  });

  ResultFuture<CenterEntity> getCenterById(String id);

  ResultFuture<List<BranchEntity>> getBranches(String centerId);

  ResultFuture<List<CenterEntity>> getAllCenters();
}
