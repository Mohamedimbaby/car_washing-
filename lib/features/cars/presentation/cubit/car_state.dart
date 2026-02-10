import 'package:equatable/equatable.dart';
import '../../domain/entities/car_entity.dart';

abstract class CarState extends Equatable {
  const CarState();

  @override
  List<Object?> get props => [];
}

class CarInitial extends CarState {}

class CarLoading extends CarState {}

class CarsLoaded extends CarState {
  final List<CarEntity> cars;

  const CarsLoaded(this.cars);

  @override
  List<Object?> get props => [cars];
}

class CarAdded extends CarState {
  final CarEntity car;

  const CarAdded(this.car);

  @override
  List<Object?> get props => [car];
}

class CarUpdated extends CarState {
  final CarEntity car;

  const CarUpdated(this.car);

  @override
  List<Object?> get props => [car];
}

class CarDeleted extends CarState {}

class CarError extends CarState {
  final String message;

  const CarError(this.message);

  @override
  List<Object?> get props => [message];
}
