import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/package_entity.dart';

class PackageModel extends PackageEntity {
  const PackageModel({
    required super.id,
    required super.providerId,
    required super.appId,
    required super.name,
    required super.nameAr,
    required super.description,
    required super.descriptionAr,
    required super.price,
    super.currency,
    required super.durationMinutes,
    required super.services,
    super.imageUrl,
    super.isActive,
    required super.createdAt,
  });

  factory PackageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PackageModel(
      id: doc.id,
      providerId: data['providerId'] ?? '',
      appId: data['appId'] ?? '',
      name: data['name'] ?? '',
      nameAr: data['nameAr'] ?? '',
      description: data['description'] ?? '',
      descriptionAr: data['descriptionAr'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      currency: data['currency'] ?? 'EGP',
      durationMinutes: data['duration'] ?? 0,
      services: List<String>.from(data['services'] ?? []),
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'providerId': providerId,
      'appId': appId,
      'name': name,
      'nameAr': nameAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'price': price,
      'currency': currency,
      'duration': durationMinutes,
      'services': services,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
