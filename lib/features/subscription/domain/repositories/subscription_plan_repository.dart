import '../entities/subscription_plan.dart';

abstract class SubscriptionPlanRepository {
  Future<List<SubscriptionPlan>> getPlans();
}
