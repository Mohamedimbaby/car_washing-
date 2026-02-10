import '../../../../core/network/dio_client.dart';
import '../models/vehicle_model.dart';

abstract class VehicleRemoteDataSource {
  Future<List<VehicleModel>> getVehicles();
  Future<VehicleModel> getVehicleById(String id);
  Future<VehicleModel> addVehicle({
    required String make,
    required String model,
    required String color,
    required String licensePlate,
    required int year,
    String? imageUrl,
  });
  Future<void> updateVehicle({
    required String id,
    String? make,
    String? model,
    String? color,
    String? licensePlate,
    int? year,
    String? imageUrl,
  });
  Future<void> deleteVehicle(String id);
  Future<void> setDefaultVehicle(String id);
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final DioClient client;

  VehicleRemoteDataSourceImpl(this.client);

  @override
  Future<List<VehicleModel>> getVehicles() async {
    try {
      final response = await client.dio.get('/vehicles');
      final List vehicles = response.data['vehicles'];
      return vehicles.map((v) => VehicleModel.fromJson(v)).toList();
    } catch (e) {
      throw Exception('Failed to get vehicles: $e');
    }
  }

  @override
  Future<VehicleModel> getVehicleById(String id) async {
    try {
      final response = await client.dio.get('/vehicles/$id');
      return VehicleModel.fromJson(response.data['vehicle']);
    } catch (e) {
      throw Exception('Failed to get vehicle: $e');
    }
  }

  @override
  Future<VehicleModel> addVehicle({
    required String make,
    required String model,
    required String color,
    required String licensePlate,
    required int year,
    String? imageUrl,
  }) async {
    try {
      final response = await client.dio.post(
        '/vehicles',
        data: {
          'make': make,
          'model': model,
          'color': color,
          'licensePlate': licensePlate,
          'year': year,
          'imageUrl': imageUrl,
        },
      );
      return VehicleModel.fromJson(response.data['vehicle']);
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  @override
  Future<void> updateVehicle({
    required String id,
    String? make,
    String? model,
    String? color,
    String? licensePlate,
    int? year,
    String? imageUrl,
  }) async {
    try {
      await client.dio.put(
        '/vehicles/$id',
        data: {
          if (make != null) 'make': make,
          if (model != null) 'model': model,
          if (color != null) 'color': color,
          if (licensePlate != null) 'licensePlate': licensePlate,
          if (year != null) 'year': year,
          if (imageUrl != null) 'imageUrl': imageUrl,
        },
      );
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await client.dio.delete('/vehicles/$id');
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  @override
  Future<void> setDefaultVehicle(String id) async {
    try {
      await client.dio.put('/vehicles/$id/set-default');
    } catch (e) {
      throw Exception('Failed to set default vehicle: $e');
    }
  }
}
