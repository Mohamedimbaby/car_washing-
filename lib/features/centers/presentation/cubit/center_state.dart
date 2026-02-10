import 'package:equatable/equatable.dart';
import '../../domain/entities/center_entity.dart';
import '../../domain/entities/branch_entity.dart';

abstract class CenterState extends Equatable {
  const CenterState();

  @override
  List<Object?> get props => [];
}

class CenterInitial extends CenterState {}

class CenterLoading extends CenterState {}

class CentersLoaded extends CenterState {
  final List<CenterEntity> centers;

  const CentersLoaded(this.centers);

  @override
  List<Object?> get props => [centers];
}

class CenterDetailsLoaded extends CenterState {
  final CenterEntity center;
  final List<BranchEntity> branches;

  const CenterDetailsLoaded(this.center, this.branches);

  @override
  List<Object?> get props => [center, branches];
}

class CenterError extends CenterState {
  final String message;

  const CenterError(this.message);

  @override
  List<Object?> get props => [message];
}
