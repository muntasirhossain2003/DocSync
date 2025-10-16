class Subscription {
  final String id;
  final String userId;
  final String status;
  final DateTime startAt;
  final DateTime endAt;
  final bool autoRenew;
  final String? planId;

  const Subscription({
    required this.id,
    required this.userId,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.autoRenew,
    this.planId,
  });

  bool get isActive => status == 'active';
}
