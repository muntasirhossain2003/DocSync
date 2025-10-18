// lib/features/booking/domain/models/payment_method.dart

enum PaymentType {
  subscription, // Using active subscription
  bkash,
  nagad,
  card,
  cash,
}

class PaymentMethod {
  final PaymentType type;
  final String displayName;
  final String? iconPath;
  final bool isEnabled;

  PaymentMethod({
    required this.type,
    required this.displayName,
    this.iconPath,
    this.isEnabled = true,
  });

  factory PaymentMethod.subscription() {
    return PaymentMethod(
      type: PaymentType.subscription,
      displayName: 'Use Subscription',
      isEnabled: true,
    );
  }

  factory PaymentMethod.bkash() {
    return PaymentMethod(
      type: PaymentType.bkash,
      displayName: 'bKash',
      isEnabled: true,
    );
  }

  factory PaymentMethod.nagad() {
    return PaymentMethod(
      type: PaymentType.nagad,
      displayName: 'Nagad',
      isEnabled: true,
    );
  }

  factory PaymentMethod.card() {
    return PaymentMethod(
      type: PaymentType.card,
      displayName: 'Credit/Debit Card',
      isEnabled: true,
    );
  }

  factory PaymentMethod.cash() {
    return PaymentMethod(
      type: PaymentType.cash,
      displayName: 'Cash on Visit',
      isEnabled: false, // Disabled for video consultations
    );
  }

  static List<PaymentMethod> allMethods() {
    return [
      PaymentMethod.subscription(),
      PaymentMethod.bkash(),
      PaymentMethod.nagad(),
      PaymentMethod.card(),
    ];
  }
}

class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  final PaymentType paymentType;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
    required this.paymentType,
  });

  factory PaymentResult.success({
    required String transactionId,
    required PaymentType paymentType,
  }) {
    return PaymentResult(
      success: true,
      transactionId: transactionId,
      paymentType: paymentType,
    );
  }

  factory PaymentResult.failure({
    required String errorMessage,
    required PaymentType paymentType,
  }) {
    return PaymentResult(
      success: false,
      errorMessage: errorMessage,
      paymentType: paymentType,
    );
  }
}
