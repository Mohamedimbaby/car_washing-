import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/car_entity.dart';

class CarModel extends CarEntity {
  const CarModel({
    required super.id,
    required super.userId,
    required super.appId,
    required super.plateNumber,
    required super.brand,
    required super.model,
    required super.color,
    required super.year,
    required super.imageUrl,
    super.isDefault,
    required super.createdAt,
  });

  factory CarModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CarModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      appId: data['appId'] ?? '',
      plateNumber: data['plateNumber'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      color: data['color'] ?? '',
      year: data['year'] ?? 2020,
      imageUrl: data['imageUrl'] ?? '',
      isDefault: data['isDefault'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'appId': appId,
      'plateNumber': plateNumber,
      'brand': brand,
      'model': model,
      'color': color,
      'year': year,
      'imageUrl': imageUrl,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CarModel.fromEntity(CarEntity entity) {
    return CarModel(
      id: entity.id,
      userId: entity.userId,
      appId: entity.appId,
      plateNumber: entity.plateNumber,
      brand: entity.brand,
      model: entity.model,
      color: entity.color,
      year: entity.year,
      imageUrl: entity.imageUrl,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
    );
  }
}
