import 'package:equatable/equatable.dart';

class VehicleEntity extends Equatable {
  final String id;
  final String userId;
  final String make;
  final String model;
  final String color;
  final String licensePlate;
  final int year;
  final String? imageUrl;
  final bool isDefault;
  final DateTime createdAt;

  const VehicleEntity({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    required this.color,
    required this.licensePlate,
    required this.year,
    this.imageUrl,
    this.isDefault = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        make,
        model,
        color,
        licensePlate,
        year,
        imageUrl,
        isDefault,
        createdAt,
      ];
}
