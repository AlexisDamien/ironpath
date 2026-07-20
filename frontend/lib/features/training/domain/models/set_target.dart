class SetTarget {
  final int setOrder;
  final int? targetReps;
  final double? targetWeight;
  final int? restSeconds;
  final bool isWarmup;

  SetTarget({
    required this.setOrder,
    this.targetReps,
    this.targetWeight,
    this.restSeconds,
    this.isWarmup = false,
  });
}
