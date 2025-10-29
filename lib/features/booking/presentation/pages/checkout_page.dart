// lib/features/booking/presentation/pages/checkout_page.dart

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_constants.dart';
import '../../../home/presentation/providers/consultation_provider.dart';
import '../../domain/models/consultation.dart';
import '../../domain/models/payment_method.dart';
import '../providers/booking_provider.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final Consultation consultation;

  const CheckoutPage({super.key, required this.consultation});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  PaymentType? _selectedPaymentMethod;
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Get the final amount (discounted if subscription exists)
    final discountInfo = await ref.read(
      discountedFeeProvider(widget.consultation.fee).future,
    );
    final finalAmount = (discountInfo['discountedFee'] as num).toDouble();

    final success = await ref
        .read(paymentProvider.notifier)
        .processPayment(
          consultation: widget.consultation,
          paymentType: _selectedPaymentMethod!,
          finalAmount: finalAmount,
        );

    setState(() => _isProcessing = false);

    if (success && mounted) {
      // Show success dialog
      _showSuccessDialog();
    } else if (mounted) {
      final error = ref.read(paymentProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Payment failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        ),
        title: Column(
          children: [
            Icon(
              FluentIcons.checkmark_circle_24_filled,
              color: Colors.green,
              size: 64,
            ),
            SizedBox(height: AppConstants.spacingMD),
            const Text('Booking Confirmed!', textAlign: TextAlign.center),
          ],
        ),
        content: Text(
          'Your consultation has been booked successfully. You can join the video call 5 minutes before the scheduled time.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog and navigate to home
              Navigator.of(context).pop();
              // Ensure upcoming schedule is refreshed on Home
              ref.invalidate(upcomingConsultationsProvider);
              context.go('/home');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Checkout', style: textTheme.titleLarge),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Consultation Summary Card
            _buildSummaryCard(colorScheme, textTheme),

            SizedBox(height: AppConstants.spacingLG),

            // Payment Methods
            Text(
              'Select Payment Method',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppConstants.spacingMD),

            // bKash
            _buildPaymentMethodCard(
              type: PaymentType.bkash,
              icon: FluentIcons.money_24_filled,
              title: 'bKash',
              subtitle: 'Pay with bKash mobile wallet',
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            SizedBox(height: AppConstants.spacingSM),

            // Nagad
            _buildPaymentMethodCard(
              type: PaymentType.nagad,
              icon: FluentIcons.money_24_filled,
              title: 'Nagad',
              subtitle: 'Pay with Nagad mobile wallet',
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            SizedBox(height: AppConstants.spacingSM),

            // Card
            _buildPaymentMethodCard(
              type: PaymentType.card,
              icon: FluentIcons.payment_24_filled,
              title: 'Credit/Debit Card',
              subtitle: 'Pay with your card',
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),

            SizedBox(height: AppConstants.spacingXL),

            // Total and Pay Button
            _buildPaymentSummary(colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: AppConstants.elevationLevel1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FluentIcons.calendar_24_filled,
                  color: colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: AppConstants.spacingSM),
                Text(
                  'Consultation Summary',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(
              height: AppConstants.spacingLG,
              color: colorScheme.outlineVariant,
            ),
            _buildInfoRow('Doctor', widget.consultation.doctorName, textTheme),
            SizedBox(height: AppConstants.spacingSM),
            _buildInfoRow(
              'Date',
              _formatDate(widget.consultation.scheduledTime),
              textTheme,
            ),
            SizedBox(height: AppConstants.spacingSM),
            _buildInfoRow(
              'Time',
              _formatTime(widget.consultation.scheduledTime),
              textTheme,
            ),
            SizedBox(height: AppConstants.spacingSM),
            _buildInfoRow(
              'Type',
              widget.consultation.type.name.toUpperCase(),
              textTheme,
            ),
            SizedBox(height: AppConstants.spacingSM),
            _buildInfoRow(
              'Consultation Fee',
              '৳${widget.consultation.fee.toStringAsFixed(0)}',
              textTheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required PaymentType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final isSelected = _selectedPaymentMethod == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = type;
        });
      },
      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      child: Container(
        padding: EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withOpacity(0.3)
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppConstants.spacingSM),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withOpacity(0.1)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            SizedBox(width: AppConstants.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Radio<PaymentType>(
              value: type,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              activeColor: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Widget _buildPaymentSummary(ColorScheme colorScheme, TextTheme textTheme) {
    final discountInfoAsync = ref.watch(
      discountedFeeProvider(widget.consultation.fee),
    );

    return discountInfoAsync.when(
      data: (discountInfo) {
        final originalFee = (discountInfo['originalFee'] as num).toDouble();
        final discountPercentage = (discountInfo['discountPercentage'] as num)
            .toInt();
        final discountedFee = (discountInfo['discountedFee'] as num).toDouble();
        final hasSubscription = discountInfo['hasSubscription'] as bool;
        final planName = discountInfo['planName'] as String?;

        return Container(
          padding: EdgeInsets.all(AppConstants.spacingMD),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          ),
          child: Column(
            children: [
              // Original Fee
              if (hasSubscription && discountPercentage > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Consultation Fee',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '৳${originalFee.toStringAsFixed(0)}',
                      style: textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppConstants.spacingSM),
                // Discount
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingSM,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            FluentIcons.tag_24_filled,
                            color: Colors.green,
                            size: 16,
                          ),
                          SizedBox(width: AppConstants.spacingXS),
                          Text(
                            '$planName Discount ($discountPercentage% OFF)',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '-৳${(originalFee - discountedFee).toStringAsFixed(0)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppConstants.spacingMD),
                Divider(color: colorScheme.outlineVariant),
                SizedBox(height: AppConstants.spacingMD),
              ],
              // Final Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '৳${discountedFee.toStringAsFixed(0)}',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasSubscription && discountPercentage > 0
                          ? Colors.green
                          : colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (hasSubscription && discountPercentage > 0)
                Padding(
                  padding: EdgeInsets.only(top: AppConstants.spacingXS),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'You saved ৳${(originalFee - discountedFee).toStringAsFixed(0)}!',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: AppConstants.spacingMD),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing || _selectedPaymentMethod == null
                      ? null
                      : _processPayment,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: AppConstants.spacingLG,
                    ),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMD,
                      ),
                    ),
                  ),
                  child: _isProcessing
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          'Confirm Payment',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.surface,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Container(
        padding: EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '৳${widget.consultation.fee.toStringAsFixed(0)}',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.spacingMD),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing || _selectedPaymentMethod == null
                    ? null
                    : _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: AppConstants.spacingLG,
                  ),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  ),
                ),
                child: _isProcessing
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(
                        'Confirm Payment',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
