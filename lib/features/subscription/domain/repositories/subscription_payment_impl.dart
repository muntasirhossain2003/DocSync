import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_payment.dart';
import '../../domain/repositories/subscription_payment_repository.dart';
import '../../data/datasources/subscription_payment.dart';

class SubscriptionPaymentRepositoryImpl implements SubscriptionPaymentRepository {
  final SubscriptionPaymentRemoteDataSource remoteDataSource;
  SubscriptionPaymentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Subscription> createPendingSubscription(String userId, String planId) {
    return remoteDataSource.createPendingSubscription(userId, planId);
  }

  @override
  Future<SubscriptionPayment> createPayment({
    required String userId,
    required String subscriptionId,
    required double amount,
    required String paymentMethod,
    required double paymentNumber
  }) {
    return remoteDataSource.createPayment(
      userId: userId,
      subscriptionId: subscriptionId,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentNumber: paymentNumber
    );
  }
}