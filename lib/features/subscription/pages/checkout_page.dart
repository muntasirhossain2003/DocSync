// presentation/pages/subscription_checkout_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/theme.dart';
import '../provider/subscription_payment_provider.dart';
import '../../subscription/domain/entities/subscription_plan.dart';

class SubscriptionCheckoutPage extends ConsumerStatefulWidget {
  final SubscriptionPlan plan;
  const SubscriptionCheckoutPage({super.key, required this.plan});

  @override
  ConsumerState<SubscriptionCheckoutPage> createState() =>
      _SubscriptionCheckoutPageState();
}

class _SubscriptionCheckoutPageState
    extends ConsumerState<SubscriptionCheckoutPage> {
  String _selectedMethod = 'bKash';
  bool _isLoading = false;
  final _methods = ['bKash', 'Nagad', 'Credit Card', 'Debit Card'];

  final TextEditingController _paymentNumberController =
      TextEditingController();

  @override
  void dispose() {
    _paymentNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.dark_blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Plan Details Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow(theme, 'Plan', widget.plan.name),
                    const SizedBox(height: 12),
                    _buildRow(
                      theme,
                      'Cost',
                      '\$${widget.plan.rate.toStringAsFixed(2)}',
                      valueColor: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    _buildRow(
                      theme,
                      'Discount',
                      '${widget.plan.rate.toStringAsFixed(0)}%',
                      valueColor: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey[300], thickness: 1),
                  ],
                ),
              ),
            ),

            /// Payment Method Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Method',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedMethod,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _methods
                          .map((method) =>
                              DropdownMenuItem(value: method, child: Text(method)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedMethod = v);
                      },
                    ),
                  ],
                ),
              ),
            ),

            /// Payment Number Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Number',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _paymentNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter your payment number',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Pay Button
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        if (user == null) return;

                        final paymentNumberText =
                            _paymentNumberController.text.trim();
                        if (paymentNumberText.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please enter a payment number')),
                          );
                          return;
                        }

                        double paymentNumber;
                        try {
                          paymentNumber = double.parse(paymentNumberText);
                        } catch (_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Invalid payment number')),
                          );
                          return;
                        }

                        setState(() => _isLoading = true);

                        try {
                          final userRow = await Supabase.instance.client
                              .from('users')
                              .select('id')
                              .eq('auth_id', user.id)
                              .maybeSingle();

                          if (userRow == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('User not found in database')),
                            );
                            return;
                          }

                          final internalUserId = userRow['id'];

                          final createSub =
                              ref.read(createPendingSubscriptionProvider);
                          final subscription =
                              await createSub(internalUserId, widget.plan.id);

                          final createPayment =
                              ref.read(createSubscriptionPaymentProvider);
                          await createPayment(
                            userId: internalUserId,
                            subscriptionId: subscription.id,
                            amount: widget.plan.rate.toDouble(),
                            paymentMethod: _selectedMethod,
                            paymentNumber: paymentNumber,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Payment initiated, status: pending')),
                          );

                          Navigator.pop(context);
                        } finally {
                          setState(() => _isLoading = false);
                        }
                      },
                      child: const Text('Upgrade'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  /// Helper to build label-value rows in plan details
  Widget _buildRow(ThemeData theme, String label, String value,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: valueColor ?? theme.textTheme.titleLarge?.color,
            )),
      ],
    );
  }
}
