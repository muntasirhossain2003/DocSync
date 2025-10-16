import '../entities/subscription.dart';
import './subscription_repository.dart';
import '../../data/datasources/subscription_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository
{
  final SubscriptionDatasource datasource;

  SubscriptionRepositoryImpl(this.datasource);

  @override
  Future<Subscription?> getUserSubscription(String userId)
  {
    return datasource.fetchUserSubscription(userId);
  }
}