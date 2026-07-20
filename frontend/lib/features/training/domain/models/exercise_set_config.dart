class ExerciseSetConfig {
  final int setOrder;
  final int? targetReps;
  final double? targetWeight;
  final int? restSeconds;
  final bool isWarmup;

  ExerciseSetConfig({
    required this.setOrder,
    this.targetReps,
    this.targetWeight,
    this.restSeconds,
    this.isWarmup = false,
  });
}
