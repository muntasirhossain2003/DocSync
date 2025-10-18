// domain/usecases/get_subscription_plans.dart
import '../entities/subscription_plan.dart';
import '../repositories/subscription_plan_repository.dart';

class GetSubscriptionPlans {
  final SubscriptionPlanRepository repository;

  GetSubscriptionPlans(this.repository);

  Future<List<SubscriptionPlan>> call() {
    return repository.getPlans();
  }
}
