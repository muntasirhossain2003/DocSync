class SubscriptionPayment {
  final String id;
  final String userId;
  final String subscriptionId;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  final double paymentNumber;

  SubscriptionPayment({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.paymentNumber
  });
}