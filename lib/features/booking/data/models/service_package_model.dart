import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/service_package_entity.dart';

class ServicePackageModel extends ServicePackageEntity {
  const ServicePackageModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.type,
    required super.durationMinutes,
    required super.features,
    super.imageUrl,
  });

  factory ServicePackageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServicePackageModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num).toDouble(),
      type: _parsePackageType(data['type']),
      durationMinutes: data['durationMinutes'] ?? 0,
      features: List<String>.from(data['features'] ?? []),
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'type': type.toString().split('.').last,
      'durationMinutes': durationMinutes,
      'features': features,
      'imageUrl': imageUrl,
    };
  }

  static PackageType _parsePackageType(String? type) {
    switch (type) {
      case 'basic':
        return PackageType.basic;
      case 'standard':
        return PackageType.standard;
      case 'premium':
        return PackageType.premium;
      case 'detailing':
        return PackageType.detailing;
      default:
        return PackageType.basic;
    }
  }
}
