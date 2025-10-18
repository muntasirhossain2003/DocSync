import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class GetUserSubscription {
  final SubscriptionRepository repository;

  GetUserSubscription(this.repository);

  Future<Subscription?> call(String userId)
  {
    return repository.getUserSubscription(userId);
  }
}