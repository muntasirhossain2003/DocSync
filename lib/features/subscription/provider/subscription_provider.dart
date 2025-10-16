import 'package:http/http.dart';

import '../data/datasources/subscription_datasource.dart';
import '../domain/entities/subscription.dart';
import '../domain/usecases/get_user_subscription.dart';
import '../domain/repositories/subscription_repostiory_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider((ref) => 
Supabase.instance.client);

final subscriptionDataProvider = Provider((ref){
  final client = ref.watch(supabaseClientProvider);
  return SubscriptionDatasource(client);
});

final subscriptionRepositoryProvider = Provider((ref){
  final datasource = ref.watch(subscriptionDataProvider);
  return SubscriptionRepositoryImpl(datasource);
});

final getSubscriptionUserProvider = Provider((ref){
  final repo = ref.watch(subscriptionRepositoryProvider);
  return GetUserSubscription(repo);
});

final userSubscriptionProvider =
  FutureProvider.autoDispose<Subscription?>((ref) async{
    final user = Supabase.instance.client.auth.currentUser;
    if(user == null) return null;

    final getUserSubscription = ref.watch(getSubscriptionUserProvider);
    return getUserSubscription(user.id);
  });