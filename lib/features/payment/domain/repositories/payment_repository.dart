import '../../../../core/utils/typedef.dart';
import '../entities/payment_method_entity.dart';
import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  ResultFuture<List<PaymentMethodEntity>> getPaymentMethods();

  ResultFuture<PaymentMethodEntity> addPaymentMethod({
    required PaymentMethodType type,
    required Map<String, dynamic> details,
  });

  ResultVoid deletePaymentMethod(String id);

  ResultVoid setDefaultPaymentMethod(String id);

  ResultFuture<PaymentEntity> processPayment({
    required String bookingId,
    required double amount,
    required String paymentMethodId,
  });

  ResultFuture<PaymentEntity> getPaymentById(String id);
}
