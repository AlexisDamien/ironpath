import 'exercise.dart';
import 'exercise_set_config.dart';

class ExerciseConfig {
  final Exercise exercise;
  final bool sameConfigForAllSets;
  final List<ExerciseSetConfig> sets;

  ExerciseConfig({
    required this.exercise,
    this.sameConfigForAllSets = true,
    required this.sets,
  });

  int get setsCount => sets.length;
}
