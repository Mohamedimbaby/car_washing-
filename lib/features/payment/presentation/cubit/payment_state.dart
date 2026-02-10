import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/payment_entity.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentMethodsLoaded extends PaymentState {
  final List<PaymentMethodEntity> paymentMethods;

  const PaymentMethodsLoaded(this.paymentMethods);

  @override
  List<Object?> get props => [paymentMethods];
}

class PaymentProcessing extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final PaymentEntity payment;

  const PaymentSuccess(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
