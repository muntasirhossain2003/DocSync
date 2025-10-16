import '../entities/subscription_payment.dart';
import '../repositories/subscription_payment_repository.dart';

class CreateSubscriptionPayment {
  final SubscriptionPaymentRepository repository;
  CreateSubscriptionPayment(this.repository);

  Future<SubscriptionPayment> call({
    required String userId,
    required String subscriptionId,
    required double amount,
    required String paymentMethod,
    required double paymentNumber
  }) {
    return repository.createPayment(
      userId: userId,
      subscriptionId: subscriptionId,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentNumber: paymentNumber
    );
  }
}