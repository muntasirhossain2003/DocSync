// presentation/pages/subscription_status_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../provider/subscription_provider.dart';

class SubscriptionStatusPage extends ConsumerWidget {
  const SubscriptionStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(userSubscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Status'),
      ),
      body: subscriptionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error: $err'),
        ),
        data: (subscription) {
          // Case 1: No subscription
          if (subscription == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "You do not have any subscriptions yet.",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.push('/profile/subscription/plans'), // absolute path
                    child: const Text("View Subscription Plans"),
                  ),
                ],
              ),
            );
          }

          // Case 2: Active subscription
          else if (subscription.isActive) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Active Subscription",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ends on: ${subscription.endAt.toLocal()}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Case 3: Inactive / expired subscription
          else {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Subscription is ${subscription.status}.",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () =>
                        context.push('/profile/subscription/plans'),
                    child: const Text("View Subscription Plans"),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
