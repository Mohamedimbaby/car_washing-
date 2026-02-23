import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_nearby_centers_usecase.dart';
import '../../domain/usecases/search_centers_usecase.dart';
import '../../domain/usecases/get_center_by_id_usecase.dart';
import 'center_state.dart';

class CenterCubit extends Cubit<CenterState> {
  final GetNearbyCentersUseCase getNearbyCentersUseCase;
  final SearchCentersUseCase searchCentersUseCase;
  final GetCenterByIdUseCase getCenterByIdUseCase;

  CenterCubit({
    required this.getNearbyCentersUseCase,
    required this.searchCentersUseCase,
    required this.getCenterByIdUseCase,
  }) : super(CenterInitial());

  Future<void> loadNearbyCenters({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    emit(CenterLoading());
    final result = await getNearbyCentersUseCase(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
    result.fold(
      (failure) => emit(CenterError(failure.message)),
      (centers) => emit(CentersLoaded(centers)),
    );
  }

  Future<void> searchCenters({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    emit(CenterLoading());
    final result = await searchCentersUseCase(
      query: query,
      latitude: latitude,
      longitude: longitude,
    );
    result.fold(
      (failure) => emit(CenterError(failure.message)),
      (centers) => emit(CentersLoaded(centers)),
    );
  }

  Future<void> loadCenterDetails(String id) async {
    emit(CenterLoading());
    final result = await getCenterByIdUseCase(id);
    result.fold(
      (failure) => emit(CenterError(failure.message)),
      (center) => emit(CenterDetailsLoaded(center, const [])),
    );
  }
}
