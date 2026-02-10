import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, processing, success, failed, refunded }

class PaymentEntity extends Equatable {
  final String id;
  final String bookingId;
  final String userId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String paymentMethodId;
  final String? transactionId;
  final DateTime createdAt;

  const PaymentEntity({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethodId,
    this.transactionId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        userId,
        amount,
        currency,
        status,
        paymentMethodId,
        transactionId,
        createdAt,
      ];
}
