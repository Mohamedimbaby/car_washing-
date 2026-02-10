import 'package:equatable/equatable.dart';
import '../../domain/entities/vehicle_entity.dart';

abstract class VehicleState extends Equatable {
  const VehicleState();

  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehiclesLoaded extends VehicleState {
  final List<VehicleEntity> vehicles;

  const VehiclesLoaded(this.vehicles);

  @override
  List<Object?> get props => [vehicles];
}

class VehicleAdded extends VehicleState {
  final VehicleEntity vehicle;

  const VehicleAdded(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError(this.message);

  @override
  List<Object?> get props => [message];
}
