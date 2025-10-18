import '../entities/subscription_payment.dart';
import '../entities/subscription.dart';

abstract class SubscriptionPaymentRepository {
  Future<Subscription> createPendingSubscription(String userId, String planId);
  Future<SubscriptionPayment> createPayment({
    required String userId,
    required String subscriptionId,
    required double amount,
    required String paymentMethod,
    required double paymentNumber
  });
}