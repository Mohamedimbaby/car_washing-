import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/schedule_config_entity.dart';
import '../../domain/usecases/delete_schedule_config_usecase.dart';
import '../../domain/usecases/generate_monthly_slots_usecase.dart';
import '../../domain/usecases/get_schedule_config_usecase.dart';
import '../../domain/usecases/save_schedule_config_usecase.dart';
import 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final GetScheduleConfigUseCase getScheduleConfig;
  final SaveScheduleConfigUseCase saveScheduleConfig;
  final GenerateMonthlySlotsUseCase generateMonthlySlots;
  final DeleteScheduleConfigUseCase deleteScheduleConfig;

  ScheduleCubit({
    required this.getScheduleConfig,
    required this.saveScheduleConfig,
    required this.generateMonthlySlots,
    required this.deleteScheduleConfig,
  }) : super(ScheduleInitial());

  Future<void> loadScheduleConfig(String providerId) async {
    emit(ScheduleLoading());
    final result = await getScheduleConfig(providerId);
    result.fold(
      (failure) => emit(ScheduleError(failure.message)),
      (config) => emit(ScheduleConfigLoaded(config)),
    );
  }

  Future<void> saveConfig(ScheduleConfigEntity config) async {
    emit(ScheduleLoading());
    final result = await saveScheduleConfig(config);
    result.fold(
      (failure) => emit(ScheduleError(failure.message)),
      (_) {
        emit(const ScheduleSaved('Schedule configuration saved successfully'));
        loadScheduleConfig(config.providerId);
      },
    );
  }

  Future<void> generateSlots({
    required String providerId,
    required DateTime month,
  }) async {
    emit(const ScheduleGenerating(0.0));
    
    final result = await generateMonthlySlots(
      providerId: providerId,
      month: month,
    );

    result.fold(
      (failure) => emit(ScheduleError(failure.message)),
      (_) {
        emit(const SlotsGenerated(
          'Monthly slots generated successfully',
          0, // TODO: Return actual count from usecase
        ));
        loadScheduleConfig(providerId);
      },
    );
  }

  Future<void> deleteConfig(String configId, String providerId) async {
    emit(ScheduleLoading());
    final result = await deleteScheduleConfig(configId);
    result.fold(
      (failure) => emit(ScheduleError(failure.message)),
      (_) {
        emit(const ScheduleSaved('Schedule configuration deleted'));
        loadScheduleConfig(providerId);
      },
    );
  }
}
