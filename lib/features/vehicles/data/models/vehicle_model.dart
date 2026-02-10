import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/vehicle_entity.dart';

part 'vehicle_model.g.dart';

@JsonSerializable()
class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.userId,
    required super.make,
    required super.model,
    required super.color,
    required super.licensePlate,
    required super.year,
    super.imageUrl,
    super.isDefault,
    required super.createdAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);

  factory VehicleModel.fromEntity(VehicleEntity entity) {
    return VehicleModel(
      id: entity.id,
      userId: entity.userId,
      make: entity.make,
      model: entity.model,
      color: entity.color,
      licensePlate: entity.licensePlate,
      year: entity.year,
      imageUrl: entity.imageUrl,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
    );
  }
}
