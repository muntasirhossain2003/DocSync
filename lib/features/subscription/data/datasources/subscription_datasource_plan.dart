// data/datasources/subscription_plan_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/subscription_plan.dart';

class SubscriptionPlanRemoteDataSource {
  final SupabaseClient client;
  SubscriptionPlanRemoteDataSource(this.client);

  Future<List<SubscriptionPlan>> fetchPlans() async {
    final response = await client.from('subscription_plans').select();
    // Supabase returns List<dynamic> directly now
    final data = response;
    return data
        .map((e) => SubscriptionPlan(
              id: e['id'] as String,
              name: e['name'] as String? ?? '',
              rate: e['rate'] as int? ?? 0,
              cost: e['cost'] as int? ?? 0,
              duration: e['duration'] as int? ?? 365,
            ))
        .toList();
  }

  Future<SubscriptionPlan?> fetchPlanById(String planId) async {
    final response = await client
        .from('subscription_plans')
        .select()
        .eq('id', planId)
        .maybeSingle();

    if (response == null) return null;

    return SubscriptionPlan(
      id: response['id'] as String,
      name: response['name'] as String? ?? '',
      rate: response['rate'] as int? ?? 0,
      cost: response['cost'] as int? ?? 0,
      duration: response['duration'] as int? ?? 365,
    );
  }
}
