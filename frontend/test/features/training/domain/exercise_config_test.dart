import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/models/exercise.dart';
import 'package:ironpath/features/training/domain/models/exercise_config.dart';
import 'package:ironpath/features/training/domain/models/exercise_set_config.dart';

void main() {
  final exercise = Exercise(id: 'ex-1', name: 'Squat');

  group('ExerciseConfig', () {
    test('setsCount reflects the number of sets provided', () {
      final config = ExerciseConfig(
        exercise: exercise,
        sets: [
          ExerciseSetConfig(setOrder: 1),
          ExerciseSetConfig(setOrder: 2),
          ExerciseSetConfig(setOrder: 3),
        ],
      );

      expect(config.setsCount, 3);
    });

    test('setsCount is zero when sets list is empty', () {
      final config = ExerciseConfig(exercise: exercise, sets: const []);

      expect(config.setsCount, 0);
    });

    test('sameConfigForAllSets defaults to true', () {
      final config = ExerciseConfig(exercise: exercise, sets: const []);

      expect(config.sameConfigForAllSets, isTrue);
    });

    test('sameConfigForAllSets can be overridden to false', () {
      final config = ExerciseConfig(
        exercise: exercise,
        sameConfigForAllSets: false,
        sets: const [],
      );

      expect(config.sameConfigForAllSets, isFalse);
    });
  });
}
