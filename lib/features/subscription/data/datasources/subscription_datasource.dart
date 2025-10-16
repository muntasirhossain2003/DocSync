import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/subscription.dart';

class SubscriptionDatasource {
  final SupabaseClient client;
  SubscriptionDatasource(this.client);

  Future<Subscription?> fetchUserSubscription(String userId) async{
    final response = await client
    .from('subscriptions')
    .select()
    .eq('user_id', userId)
    .maybeSingle();

    if(response == null) return null;

    return Subscription(
      id: response['id'],
      userId: response['userId'],
      status: response['status'],
      startAt: response['start_at'],
      endAt: response['end_at'],
      autoRenew: response['auto_renew'],
      planId: response['plan_id']
    );
  }
}