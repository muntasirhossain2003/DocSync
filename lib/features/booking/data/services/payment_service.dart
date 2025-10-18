// lib/features/booking/data/services/payment_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/payment_method.dart';

class PaymentService {
  final _supabase = Supabase.instance.client;

  // Check if user has an active subscription
  Future<bool> hasActiveSubscription(String userId) async {
    try {
      final response = await _supabase
          .from('subscriptions')
          .select('id, status, end_date')
          .eq('user_id', userId)
          .eq('status', 'active')
          .gte('end_date', DateTime.now().toIso8601String())
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get subscription details
  Future<Map<String, dynamic>?> getSubscriptionDetails(String userId) async {
    try {
      final response = await _supabase
          .from('subscriptions')
          .select('*, subscription_plans(*)')
          .eq('user_id', userId)
          .eq('status', 'active')
          .gte('end_at', DateTime.now().toIso8601String())
          .limit(1)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // Calculate discounted consultation fee based on subscription plan
  Future<Map<String, dynamic>> calculateDiscountedFee({
    required String userId,
    required double originalFee,
  }) async {
    try {
      final subscription = await getSubscriptionDetails(userId);

      if (subscription == null) {
        return {
          'originalFee': originalFee,
          'discountPercentage': 0,
          'discountedFee': originalFee,
          'hasSubscription': false,
        };
      }

      // Get the rate (discount percentage) from subscription plan
      final rate =
          (subscription['subscription_plans']?['rate'] as num?)?.toInt() ?? 0;
      final discountPercentage = rate;
      final discountAmount = (originalFee * discountPercentage) / 100;
      final discountedFee = originalFee - discountAmount;

      return {
        'originalFee': originalFee,
        'discountPercentage': discountPercentage,
        'discountAmount': discountAmount,
        'discountedFee': discountedFee,
        'hasSubscription': true,
        'planName':
            subscription['subscription_plans']?['name'] ?? 'Subscription',
      };
    } catch (e) {
      return {
        'originalFee': originalFee,
        'discountPercentage': 0,
        'discountedFee': originalFee,
        'hasSubscription': false,
      };
    }
  }

  // Process subscription-based payment (DUMMY - auto success)
  Future<PaymentResult> processSubscriptionPayment({
    required String userId,
    required String consultationId,
  }) async {
    try {
      // DUMMY: Just simulate a successful payment
      await Future.delayed(const Duration(seconds: 1));

      // Generate a transaction ID
      final transactionId = 'SUB_${DateTime.now().millisecondsSinceEpoch}';

      return PaymentResult.success(
        transactionId: transactionId,
        paymentType: PaymentType.subscription,
      );
    } catch (e) {
      return PaymentResult.failure(
        errorMessage: 'Failed to process subscription payment: $e',
        paymentType: PaymentType.subscription,
      );
    }
  }

  // Process bKash payment (DUMMY - auto success)
  Future<PaymentResult> processBkashPayment({
    required double amount,
    required String consultationId,
  }) async {
    try {
      // DUMMY: Just simulate a successful payment
      await Future.delayed(const Duration(seconds: 1));

      // Simulate payment success
      final transactionId = 'BKASH_${DateTime.now().millisecondsSinceEpoch}';

      return PaymentResult.success(
        transactionId: transactionId,
        paymentType: PaymentType.bkash,
      );
    } catch (e) {
      return PaymentResult.failure(
        errorMessage: 'bKash payment failed: $e',
        paymentType: PaymentType.bkash,
      );
    }
  }

  // Process Nagad payment (DUMMY - auto success)
  Future<PaymentResult> processNagadPayment({
    required double amount,
    required String consultationId,
  }) async {
    try {
      // DUMMY: Just simulate a successful payment
      await Future.delayed(const Duration(seconds: 1));

      // Simulate payment success
      final transactionId = 'NAGAD_${DateTime.now().millisecondsSinceEpoch}';

      return PaymentResult.success(
        transactionId: transactionId,
        paymentType: PaymentType.nagad,
      );
    } catch (e) {
      return PaymentResult.failure(
        errorMessage: 'Nagad payment failed: $e',
        paymentType: PaymentType.nagad,
      );
    }
  }

  // Process card payment (DUMMY - auto success)
  Future<PaymentResult> processCardPayment({
    required double amount,
    required String consultationId,
  }) async {
    try {
      // DUMMY: Just simulate a successful payment
      await Future.delayed(const Duration(seconds: 1));

      // Simulate payment success
      final transactionId = 'CARD_${DateTime.now().millisecondsSinceEpoch}';

      return PaymentResult.success(
        transactionId: transactionId,
        paymentType: PaymentType.card,
      );
    } catch (e) {
      return PaymentResult.failure(
        errorMessage: 'Card payment failed: $e',
        paymentType: PaymentType.card,
      );
    }
  }

  // Main payment processing method
  Future<PaymentResult> processPayment({
    required PaymentType paymentType,
    required String userId,
    required String consultationId,
    required double amount,
  }) async {
    switch (paymentType) {
      case PaymentType.subscription:
        return processSubscriptionPayment(
          userId: userId,
          consultationId: consultationId,
        );
      case PaymentType.bkash:
        return processBkashPayment(
          amount: amount,
          consultationId: consultationId,
        );
      case PaymentType.nagad:
        return processNagadPayment(
          amount: amount,
          consultationId: consultationId,
        );
      case PaymentType.card:
        return processCardPayment(
          amount: amount,
          consultationId: consultationId,
        );
      case PaymentType.cash:
        return PaymentResult.failure(
          errorMessage: 'Cash payment not supported for video consultations',
          paymentType: PaymentType.cash,
        );
    }
  }

  // Record payment in database
  // NOTE: Currently disabled as payments table doesn't exist in database
  // Uncomment this method when payments table is created
  /*
  Future<void> recordPayment({
    required String consultationId,
    required String userId,
    required PaymentType paymentType,
    required String transactionId,
    required double amount,
  }) async {
    try {
      await _supabase.from('payments').insert({
        'consultation_id': consultationId,
        'user_id': userId,
        'payment_type': paymentType.name,
        'transaction_id': transactionId,
        'amount': amount,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to record payment: $e');
    }
  }
  */
}
