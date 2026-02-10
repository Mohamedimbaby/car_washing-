import 'package:equatable/equatable.dart';

class CarEntity extends Equatable {
  final String id;
  final String userId;
  final String appId;
  final String plateNumber; // رقم اللوحة
  final String brand; // ماركة السيارة
  final String model; // الموديل
  final String color; // اللون
  final int year; // السنة
  final String imageUrl;
  final bool isDefault;
  final DateTime createdAt;

  const CarEntity({
    required this.id,
    required this.userId,
    required this.appId,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.color,
    required this.year,
    required this.imageUrl,
    this.isDefault = false,
    required this.createdAt,
  });

  CarEntity copyWith({
    String? id,
    String? userId,
    String? appId,
    String? plateNumber,
    String? brand,
    String? model,
    String? color,
    int? year,
    String? imageUrl,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return CarEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      appId: appId ?? this.appId,
      plateNumber: plateNumber ?? this.plateNumber,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      year: year ?? this.year,
      imageUrl: imageUrl ?? this.imageUrl,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        appId,
        plateNumber,
        brand,
        model,
        color,
        year,
        imageUrl,
        isDefault,
        createdAt,
      ];
}
