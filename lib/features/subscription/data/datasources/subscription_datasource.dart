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

    // Add null checks and safe casting
    return Subscription(
      id: response['id'] as String,
      userId: response['user_id'] as String? ?? userId, // Fallback to parameter
      status: response['status'] as String? ?? 'pending',
      startAt: response['start_at'] != null 
          ? DateTime.parse(response['start_at'] as String)
          : DateTime.now(),
      endAt: response['end_at'] != null
          ? DateTime.parse(response['end_at'] as String)
          : DateTime.now(),
      autoRenew: response['auto_renew'] as bool? ?? false,
      planId: response['plan_id'] as String? ?? '',
    );
  }
}