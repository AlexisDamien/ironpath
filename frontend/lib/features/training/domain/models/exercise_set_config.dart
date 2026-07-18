class ExerciseSetConfig {
  final int setOrder;
  final int? targetReps;
  final double? targetWeight;
  final int? restSeconds;

  ExerciseSetConfig({
    required this.setOrder,
    this.targetReps,
    this.targetWeight,
    this.restSeconds,
  });
}
