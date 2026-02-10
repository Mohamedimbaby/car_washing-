import 'package:equatable/equatable.dart';

class PackageEntity extends Equatable {
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
  final List<String> services;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;

  const PackageEntity({
    required this.id,
    required this.providerId,
    required this.appId,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.price,
    this.currency = 'EGP',
    required this.durationMinutes,
    required this.services,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
  });

  PackageEntity copyWith({
    String? id,
    String? providerId,
    String? appId,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    double? price,
    String? currency,
    int? durationMinutes,
    List<String>? services,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return PackageEntity(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      appId: appId ?? this.appId,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      services: services ?? this.services,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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
        services,
        imageUrl,
        isActive,
        createdAt,
      ];
}
