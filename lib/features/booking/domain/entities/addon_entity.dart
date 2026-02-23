import 'package:equatable/equatable.dart';

class AddonEntity extends Equatable {
  final String id;
  final String providerId;
  final String appId;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final double price;
  final String currency;
  final int durationMinutes;
  final String? iconUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AddonEntity({
    required this.id,
    required this.providerId,
    required this.appId,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.price,
    this.currency = 'EGP',
    this.durationMinutes = 0,
    this.iconUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    providerId,
    appId,
    name,
    nameAr,
    description,
    descriptionAr,
    price,
    currency,
    durationMinutes,
    iconUrl,
    isActive,
    createdAt,
    updatedAt,
  ];
}
