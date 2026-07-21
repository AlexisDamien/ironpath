import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/models/workout_program.dart';

void main() {
  group('WorkoutProgram.fromJson', () {
    test('parses a fully populated program', () {
      final program = WorkoutProgram.fromJson({
        'id': 'program-1',
        'name': 'Push Pull Legs',
        'description': 'Programme sur 3 jours',
        'isActive': true,
        'exercises': [
          {
            'id': 'pe-1',
            'exerciseId': 'ex-1',
            'exerciseOrder': 1,
            'sameConfigForAllSets': true,
            'sets': [
              {'id': 'set-1', 'setOrder': 1, 'targetReps': 10},
            ],
          },
        ],
      });

      expect(program.id, 'program-1');
      expect(program.name, 'Push Pull Legs');
      expect(program.description, 'Programme sur 3 jours');
      expect(program.isActive, isTrue);
      expect(program.exercises, hasLength(1));
    });

    test('defaults isActive to false and exercises to empty list', () {
      final program = WorkoutProgram.fromJson({
        'id': 'program-2',
        'name': 'Full Body',
      });

      expect(program.isActive, isFalse);
      expect(program.exercises, isEmpty);
      expect(program.description, isNull);
    });
  });

  group('ProgramExercise.fromJson', () {
    test('sameConfigForAllSets defaults to true when absent', () {
      final exercise = ProgramExercise.fromJson({
        'id': 'pe-1',
        'exerciseId': 'ex-1',
        'exerciseOrder': 1,
      });

      expect(exercise.sameConfigForAllSets, isTrue);
      expect(exercise.sets, isEmpty);
    });

    test('sameConfigForAllSets can be false', () {
      final exercise = ProgramExercise.fromJson({
        'id': 'pe-1',
        'exerciseId': 'ex-1',
        'exerciseOrder': 1,
        'sameConfigForAllSets': false,
      });

      expect(exercise.sameConfigForAllSets, isFalse);
    });
  });

  group('ProgramExerciseSetModel.fromJson', () {
    test('reads weight from "targetWeightKg" key', () {
      final set = ProgramExerciseSetModel.fromJson({
        'id': 'set-1',
        'setOrder': 1,
        'targetWeightKg': 55.0,
      });

      expect(set.targetWeight, 55.0);
    });

    test('isWarmup defaults to false', () {
      final set = ProgramExerciseSetModel.fromJson({
        'id': 'set-1',
        'setOrder': 1,
      });

      expect(set.isWarmup, isFalse);
    });
  });
}
