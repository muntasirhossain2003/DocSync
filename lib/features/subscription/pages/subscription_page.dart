// presentation/pages/subscription_status_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme.dart';
import '../provider/subscription_provider.dart';
import '../provider/subscription_plan_provider.dart';

class SubscriptionStatusPage extends ConsumerWidget {
  const SubscriptionStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(userSubscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Subscription',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.dark_blue,
        centerTitle: true,
        elevation: 0,
      ),
      body: subscriptionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading subscription',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ),
        data: (subscription) {
          // Case 1: No subscription
          if (subscription == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.card_membership_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "No Active Subscription",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Subscribe now to unlock premium features and get unlimited consultations!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dark_blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            context.push('/profile/subscription/plans'),
                        child: const Text(
                          "View Subscription Plans",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Case 2: Active subscription
          else if (subscription.isActive) {
            return _ActiveSubscriptionView(subscription: subscription);
          }

          // Case 3: Inactive / expired subscription
          else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cancel_outlined,
                        size: 80,
                        color: Colors.red[400],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Subscription ${subscription.status.toUpperCase()}",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Your subscription has ${subscription.status}. Renew now to continue enjoying premium features.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dark_blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            context.push('/profile/subscription/plans'),
                        child: const Text(
                          "Renew Subscription",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _ActiveSubscriptionView extends ConsumerWidget {
  final dynamic subscription;

  const _ActiveSubscriptionView({required this.subscription});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = subscription.planId != null && subscription.planId!.isNotEmpty
        ? ref.watch(subscriptionPlanByIdProvider(subscription.planId!))
        : null;

    final daysRemaining = subscription.endAt.difference(DateTime.now()).inDays;
    final dateFormat = DateFormat('MMM dd, yyyy');

    if (planAsync == null) {
      // No plan ID, show basic subscription info
      return _buildSubscriptionContent(
        context,
        subscription,
        null,
        daysRemaining,
        dateFormat,
      );
    }

    return planAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => _buildSubscriptionContent(
        context,
        subscription,
        null,
        daysRemaining,
        dateFormat,
      ),
      data: (plan) => _buildSubscriptionContent(
        context,
        subscription,
        plan,
        daysRemaining,
        dateFormat,
      ),
    );
  }

  Widget _buildSubscriptionContent(
    BuildContext context,
    subscription,
    plan,
    int daysRemaining,
    DateFormat dateFormat,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'ACTIVE SUBSCRIPTION',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Main Subscription Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [AppColors.dark_blue, AppColors.dark_blue.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Plan Name
                  Text(
                    plan?.name ?? 'Premium Plan',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${plan?.duration ?? 30} Days Plan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Days Remaining
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$daysRemaining',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Days Remaining',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Subscription Details Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscription Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    Icons.calendar_today,
                    'Start Date',
                    dateFormat.format(subscription.startAt),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    Icons.event,
                    'End Date',
                    dateFormat.format(subscription.endAt),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    Icons.autorenew,
                    'Auto Renew',
                    subscription.autoRenew ? 'Enabled' : 'Disabled',
                    valueColor: subscription.autoRenew ? Colors.green : Colors.orange,
                  ),
                  if (plan != null) ...[
                    const Divider(height: 24),
                    _buildDetailRow(
                      context,
                      Icons.attach_money,
                      'Plan Cost',
                      '৳${plan.cost.toStringAsFixed(0)}',
                      valueColor: AppColors.dark_blue,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Benefits Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitRow(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            benefit,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
