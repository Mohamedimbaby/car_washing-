// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) => VehicleModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      color: json['color'] as String,
      licensePlate: json['licensePlate'] as String,
      year: (json['year'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$VehicleModelToJson(VehicleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'make': instance.make,
      'model': instance.model,
      'color': instance.color,
      'licensePlate': instance.licensePlate,
      'year': instance.year,
      'imageUrl': instance.imageUrl,
      'isDefault': instance.isDefault,
      'createdAt': instance.createdAt.toIso8601String(),
    };
