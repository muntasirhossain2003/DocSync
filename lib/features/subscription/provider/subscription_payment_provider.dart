// presentation/providers/subscription_payment_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/datasources/subscription_payment.dart';
import '../domain/repositories/subscription_payment_impl.dart';
import '../domain/usecases/create_subscription.dart';
import '../domain/usecases/create_subscription_payment.dart';

// Supabase client
final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

// Remote Data Source
final subscriptionPaymentRemoteDataSourceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SubscriptionPaymentRemoteDataSource(client);
});

// Repository
final subscriptionPaymentRepositoryProvider = Provider((ref) {
  final remote = ref.watch(subscriptionPaymentRemoteDataSourceProvider);
  return SubscriptionPaymentRepositoryImpl(remote);
});

// Use Cases
final createPendingSubscriptionProvider = Provider((ref) {
  final repo = ref.watch(subscriptionPaymentRepositoryProvider);
  return CreatePendingSubscription(repo);
});

final createSubscriptionPaymentProvider = Provider((ref) {
  final repo = ref.watch(subscriptionPaymentRepositoryProvider);
  return CreateSubscriptionPayment(repo);
});
