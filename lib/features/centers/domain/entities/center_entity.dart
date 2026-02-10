import 'package:equatable/equatable.dart';

class CenterEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String? email;
  final String? logoUrl;
  final List<String> photoUrls;
  final double rating;
  final int reviewCount;
  final bool hasInCenterWash;
  final bool hasOnLocationWash;
  final String operatingHours;
  final bool isActive;

  const CenterEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    this.email,
    this.logoUrl,
    required this.photoUrls,
    required this.rating,
    required this.reviewCount,
    required this.hasInCenterWash,
    required this.hasOnLocationWash,
    required this.operatingHours,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        address,
        latitude,
        longitude,
        phoneNumber,
        email,
        logoUrl,
        photoUrls,
        rating,
        reviewCount,
        hasInCenterWash,
        hasOnLocationWash,
        operatingHours,
        isActive,
      ];
}
