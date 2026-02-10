import 'package:equatable/equatable.dart';

enum PackageType { basic, standard, premium, detailing }

class ServicePackageEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final PackageType type;
  final int durationMinutes;
  final List<String> features;
  final String? imageUrl;

  const ServicePackageEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.durationMinutes,
    required this.features,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        type,
        durationMinutes,
        features,
        imageUrl,
      ];
}
