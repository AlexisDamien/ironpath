import 'exercise.dart';

class ExerciseConfig {
  final Exercise exercise;
  final int targetSets;
  final int targetReps;
  final double? targetWeight;
  final int restSeconds;

  ExerciseConfig({
    required this.exercise,
    required this.targetSets,
    required this.targetReps,
    this.targetWeight,
    required this.restSeconds,
  });
}
