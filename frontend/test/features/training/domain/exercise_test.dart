import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/models/exercise.dart';
import 'package:ironpath/features/training/domain/models/exercise_config.dart';
import 'package:ironpath/features/training/domain/models/exercise_set_config.dart';

import '../../../helpers/fixtures.dart';

void main() {
  test('Exercise.fromJson convertit tous les champs', () {
    final exercise = Exercise.fromJson(exerciseJson());

    expect(exercise.id, 'exercise-1');
    expect(exercise.name, 'Développé couché');
    expect(exercise.muscleGroup, 'CHEST');
    expect(exercise.equipment, 'BARBELL');
  });

  test('ExerciseConfig expose le nombre de séries', () {
    final config = ExerciseConfig(
      exercise: exerciseFixture(),
      sets: [
        ExerciseSetConfig(setOrder: 1),
        ExerciseSetConfig(setOrder: 2, isWarmup: true),
      ],
    );

    expect(config.setsCount, 2);
    expect(config.sameConfigForAllSets, isTrue);
  });
}
