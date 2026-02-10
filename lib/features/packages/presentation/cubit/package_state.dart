import 'package:equatable/equatable.dart';
import '../../domain/entities/package_entity.dart';

abstract class PackageState extends Equatable {
  const PackageState();

  @override
  List<Object?> get props => [];
}

class PackageInitial extends PackageState {}

class PackageLoading extends PackageState {}

class PackagesLoaded extends PackageState {
  final List<PackageEntity> packages;

  const PackagesLoaded(this.packages);

  @override
  List<Object?> get props => [packages];
}

class PackageAdded extends PackageState {
  final PackageEntity package;

  const PackageAdded(this.package);

  @override
  List<Object?> get props => [package];
}

class PackageUpdated extends PackageState {
  final PackageEntity package;

  const PackageUpdated(this.package);

  @override
  List<Object?> get props => [package];
}

class PackageDeleted extends PackageState {}

class PackageError extends PackageState {
  final String message;

  const PackageError(this.message);

  @override
  List<Object?> get props => [message];
}
