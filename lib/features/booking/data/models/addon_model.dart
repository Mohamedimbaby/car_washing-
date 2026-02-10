import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/addon_entity.dart';

class AddonModel extends AddonEntity {
  const AddonModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.iconUrl,
  });

  factory AddonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddonModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num).toDouble(),
      iconUrl: data['iconUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'iconUrl': iconUrl,
    };
  }
}
