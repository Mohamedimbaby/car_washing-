import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_cars_usecase.dart';
import '../../domain/usecases/add_car_usecase.dart';
import '../../domain/usecases/update_car_usecase.dart';
import '../../domain/usecases/delete_car_usecase.dart';
import 'car_state.dart';

class CarCubit extends Cubit<CarState> {
  final GetCarsUseCase getCarsUseCase;
  final AddCarUseCase addCarUseCase;
  final UpdateCarUseCase updateCarUseCase;
  final DeleteCarUseCase deleteCarUseCase;

  CarCubit({
    required this.getCarsUseCase,
    required this.addCarUseCase,
    required this.updateCarUseCase,
    required this.deleteCarUseCase,
  }) : super(CarInitial());

  Future<void> loadCars() async {
    emit(CarLoading());
    final result = await getCarsUseCase();
    result.fold(
      (failure) => emit(CarError(failure.message)),
      (cars) => emit(CarsLoaded(cars)),
    );
  }

  Future<void> addCar({
    required String plateNumber,
    required String brand,
    required String model,
    required String color,
    required int year,
    required File imageFile,
    bool isDefault = false,
  }) async {
    emit(CarLoading());
    final result = await addCarUseCase(
      plateNumber: plateNumber,
      brand: brand,
      model: model,
      color: color,
      year: year,
      imageFile: imageFile,
      isDefault: isDefault,
    );
    result.fold(
      (failure) => emit(CarError(failure.message)),
      (car) {
        emit(CarAdded(car));
        loadCars(); // Reload list
      },
    );
  }

  Future<void> updateCar({
    required String carId,
    String? plateNumber,
    String? brand,
    String? model,
    String? color,
    int? year,
    File? imageFile,
    bool? isDefault,
  }) async {
    emit(CarLoading());
    final result = await updateCarUseCase(
      carId: carId,
      plateNumber: plateNumber,
      brand: brand,
      model: model,
      color: color,
      year: year,
      imageFile: imageFile,
      isDefault: isDefault,
    );
    result.fold(
      (failure) => emit(CarError(failure.message)),
      (car) {
        emit(CarUpdated(car));
        loadCars(); // Reload list
      },
    );
  }

  Future<void> deleteCar(String carId) async {
    emit(CarLoading());
    final result = await deleteCarUseCase(carId);
    result.fold(
      (failure) => emit(CarError(failure.message)),
      (_) {
        emit(CarDeleted());
        loadCars(); // Reload list
      },
    );
  }
}
