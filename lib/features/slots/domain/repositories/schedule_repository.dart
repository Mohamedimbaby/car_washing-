import '../../../../core/utils/typedef.dart';
import '../entities/schedule_config_entity.dart';

abstract class ScheduleRepository {
  /// Get schedule configuration for a provider
  ResultFuture<ScheduleConfigEntity?> getScheduleConfig(String providerId);

  /// Save or update schedule configuration
  ResultVoid saveScheduleConfig(ScheduleConfigEntity config);

  /// Generate monthly slots based on schedule configuration
  ResultVoid generateMonthlySlots({
    required String providerId,
    required DateTime month,
  });

  /// Delete schedule configuration
  ResultVoid deleteScheduleConfig(String configId);
}
