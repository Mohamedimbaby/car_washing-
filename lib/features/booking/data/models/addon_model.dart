import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/addon_entity.dart';

class AddonModel extends AddonEntity {
  const AddonModel({
    required super.id,
    required super.providerId,
    required super.appId,
    required super.name,
    required super.nameAr,
    required super.description,
    required super.descriptionAr,
    required super.price,
    super.currency,
    super.durationMinutes,
    super.iconUrl,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory AddonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddonModel(
      id: doc.id,
      providerId: data['providerId'] ?? '',
      appId: data['appId'] ?? '',
      name: data['name'] ?? '',
      nameAr: data['nameAr'] ?? '',
      description: data['description'] ?? '',
      descriptionAr: data['descriptionAr'] ?? '',
      price: (data['price'] as num).toDouble(),
      currency: data['currency'] ?? 'EGP',
      durationMinutes: data['durationMinutes'] ?? 0,
      iconUrl: data['iconUrl'],
      isActive: data['isActive'] ?? true,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
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
      'durationMinutes': durationMinutes,
      'iconUrl': iconUrl,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
