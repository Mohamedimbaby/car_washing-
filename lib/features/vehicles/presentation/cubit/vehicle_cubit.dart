import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_vehicles_usecase.dart';
import '../../domain/usecases/add_vehicle_usecase.dart';
import '../../domain/usecases/delete_vehicle_usecase.dart';
import 'vehicle_state.dart';

class VehicleCubit extends Cubit<VehicleState> {
  final GetVehiclesUseCase getVehiclesUseCase;
  final AddVehicleUseCase addVehicleUseCase;
  final DeleteVehicleUseCase deleteVehicleUseCase;

  VehicleCubit({
    required this.getVehiclesUseCase,
    required this.addVehicleUseCase,
    required this.deleteVehicleUseCase,
  }) : super(VehicleInitial());

  Future<void> loadVehicles() async {
    emit(VehicleLoading());
    final result = await getVehiclesUseCase();
    result.fold(
      (failure) => emit(VehicleError(failure.message)),
      (vehicles) => emit(VehiclesLoaded(vehicles)),
    );
  }

  Future<void> addVehicle({
    required String make,
    required String model,
    required String color,
    required String licensePlate,
    required int year,
    String? imageUrl,
  }) async {
    emit(VehicleLoading());
    final result = await addVehicleUseCase(
      make: make,
      model: model,
      color: color,
      licensePlate: licensePlate,
      year: year,
      imageUrl: imageUrl,
    );
    result.fold(
      (failure) => emit(VehicleError(failure.message)),
      (vehicle) {
        emit(VehicleAdded(vehicle));
        loadVehicles();
      },
    );
  }

  Future<void> deleteVehicle(String id) async {
    emit(VehicleLoading());
    final result = await deleteVehicleUseCase(id);
    result.fold(
      (failure) => emit(VehicleError(failure.message)),
      (_) => loadVehicles(),
    );
  }
}
