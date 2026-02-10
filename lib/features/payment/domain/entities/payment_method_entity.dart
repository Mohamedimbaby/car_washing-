import 'package:equatable/equatable.dart';

enum PaymentMethodType { card, wallet, cash }

class PaymentMethodEntity extends Equatable {
  final String id;
  final String userId;
  final PaymentMethodType type;
  final String? cardLast4;
  final String? cardBrand;
  final String? walletProvider;
  final bool isDefault;
  final DateTime createdAt;

  const PaymentMethodEntity({
    required this.id,
    required this.userId,
    required this.type,
    this.cardLast4,
    this.cardBrand,
    this.walletProvider,
    this.isDefault = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        cardLast4,
        cardBrand,
        walletProvider,
        isDefault,
        createdAt,
      ];
}
