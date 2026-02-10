import 'package:equatable/equatable.dart';

class AddonEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? iconUrl;

  const AddonEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.iconUrl,
  });

  @override
  List<Object?> get props => [id, name, description, price, iconUrl];
}
