import '../entities/subscription.dart';
import '../repositories/subscription_payment_repository.dart';

class CreatePendingSubscription {
  final SubscriptionPaymentRepository repository;
  CreatePendingSubscription(this.repository);

  Future<Subscription> call(String userId, String planId) {
    return repository.createPendingSubscription(userId, planId);
  }
}