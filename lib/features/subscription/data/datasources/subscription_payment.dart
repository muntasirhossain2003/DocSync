// data/datasources/subscription_payment_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/subscription_payment.dart';
import '../../domain/entities/subscription.dart';

class SubscriptionPaymentRemoteDataSource {
  final SupabaseClient client;
  SubscriptionPaymentRemoteDataSource(this.client);

  // Insert subscription row (pending)
  Future<Subscription> createPendingSubscription(String userId, String planId) async {
  final startAt = DateTime.now();
  final endAt = DateTime(startAt.year + 1, startAt.month, startAt.day, startAt.hour, startAt.minute, startAt.second);

  final response = await client.from('subscriptions').insert({
    'user_id': userId,
    'plan_id': planId,
    'status': 'pending',
    'start_at': startAt.toIso8601String(),
    'end_at': endAt.toIso8601String(),
  }).select().single();

  return Subscription(
    id: response['id'],
    userId: response['user_id'],
    planId: response['plan_id'],
    startAt: startAt,
    endAt: endAt,
    autoRenew: response['auto_renew'] ?? true,
    status: response['status'],
  );
}


  // Insert payment
  Future<SubscriptionPayment> createPayment({
    required String userId,
    required String subscriptionId,
    required double amount,
    required String paymentMethod,
    required double paymentNumber
  }) async {
    final response = await client.from('subscription_payments').insert({
      'user_id': userId,
      'subscription_id': subscriptionId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_status': 'pending',
      'payment_number': paymentNumber
    }).select().single();

    return SubscriptionPayment(
      id: response['id'],
      userId: response['user_id'],
      subscriptionId: response['subscription_id'],
      amount: double.parse(response['amount'].toString()),
      paymentMethod: response['payment_method'],
      paymentStatus: response['payment_status'],
      createdAt: DateTime.parse(response['created_at']),
      paymentNumber: response['payment_number']
    );
  }
}
