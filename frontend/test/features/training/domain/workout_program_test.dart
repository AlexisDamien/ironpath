import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/models/workout_program.dart';

import '../../../helpers/fixtures.dart';

void main() {
  test('WorkoutProgram.fromJson convertit les exercices et séries', () {
    final program = WorkoutProgram.fromJson(programJson());

    expect(program.id, 'program-1');
    expect(program.name, 'Push');
    expect(program.isActive, isTrue);
    expect(program.exercises, hasLength(1));

    final exercise = program.exercises.single;
    expect(exercise.exerciseOrder, 1);
    expect(exercise.sameConfigForAllSets, isTrue);
    expect(exercise.sets.single.targetWeight, 80.0);
    expect(exercise.sets.single.restSeconds, 90);
  });

  test('les listes manquantes deviennent vides', () {
    final json = programJson()..remove('exercises');
    expect(WorkoutProgram.fromJson(json).exercises, isEmpty);
  });

  test('isActive vaut false par défaut', () {
    final json = programJson()..remove('isActive');
    expect(WorkoutProgram.fromJson(json).isActive, isFalse);
  });
}
