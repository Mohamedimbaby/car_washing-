import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_data_source.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<List<VehicleEntity>> getVehicles() async {
    try {
      final vehicles = await remoteDataSource.getVehicles();
      return Right(vehicles);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<VehicleEntity> getVehicleById(String id) async {
    try {
      final vehicle = await remoteDataSource.getVehicleById(id);
      return Right(vehicle);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<VehicleEntity> addVehicle({
    required String make,
    required String model,
    required String color,
    required String licensePlate,
    required int year,
    String? imageUrl,
  }) async {
    try {
      final vehicle = await remoteDataSource.addVehicle(
        make: make,
        model: model,
        color: color,
        licensePlate: licensePlate,
        year: year,
        imageUrl: imageUrl,
      );
      return Right(vehicle);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid updateVehicle({
    required String id,
    String? make,
    String? model,
    String? color,
    String? licensePlate,
    int? year,
    String? imageUrl,
  }) async {
    try {
      await remoteDataSource.updateVehicle(
        id: id,
        make: make,
        model: model,
        color: color,
        licensePlate: licensePlate,
        year: year,
        imageUrl: imageUrl,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid deleteVehicle(String id) async {
    try {
      await remoteDataSource.deleteVehicle(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid setDefaultVehicle(String id) async {
    try {
      await remoteDataSource.setDefaultVehicle(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
