import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/datasources/subscription_datasource_plan.dart';
import '../domain/repositories/subscription_plan_repository_impl.dart';
import '../domain/entities/subscription_plan.dart';
import '../domain/usecases/get_subscription_plants.dart';

// Supabase client provider
final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

// Remote Data Source
final subscriptionPlanRemoteDataSourceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SubscriptionPlanRemoteDataSource(client);
});

// Repository
final subscriptionPlanRepositoryProvider = Provider((ref) {
  final remoteDataSource = ref.watch(subscriptionPlanRemoteDataSourceProvider);
  return SubscriptionPlanRepositoryImpl(remoteDataSource);
});

// Use case
final getSubscriptionPlansProvider = Provider((ref) {
  final repository = ref.watch(subscriptionPlanRepositoryProvider);
  return GetSubscriptionPlans(repository);
});

// FutureProvider to fetch subscription plans
final subscriptionPlansProvider =
    FutureProvider<List<SubscriptionPlan>>((ref) async {
  final getPlans = ref.watch(getSubscriptionPlansProvider);
  return getPlans();
});

// FutureProvider to fetch a single subscription plan by ID
final subscriptionPlanByIdProvider =
    FutureProvider.family<SubscriptionPlan?, String>((ref, planId) async {
  if (planId.isEmpty) return null;
  final dataSource = ref.watch(subscriptionPlanRemoteDataSourceProvider);
  return dataSource.fetchPlanById(planId);
});
