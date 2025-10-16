import '../../domain/repositories/subscription_plan_repository.dart';
import '../entities/subscription_plan.dart';
import '../../data/datasources/subscription_datasource_plan.dart';

class SubscriptionPlanRepositoryImpl implements SubscriptionPlanRepository {
  final SubscriptionPlanRemoteDataSource remoteDataSource;

  SubscriptionPlanRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<SubscriptionPlan>> getPlans() {
    return remoteDataSource.fetchPlans();
  }
}
