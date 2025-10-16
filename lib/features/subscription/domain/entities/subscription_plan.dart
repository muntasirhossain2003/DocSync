class SubscriptionPlan {
  final String id;
  final String name;
  final int rate;
  final int cost;
  final int duration; // in days

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.rate,
    required this.cost,
    required this.duration,
  });
}
