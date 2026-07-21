import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/models/training_session.dart';

void main() {
  group('TrainingSession.fromJson', () {
    test('parses a fully populated session', () {
      final session = TrainingSession.fromJson({
        'id': 'session-1',
        'name': 'Séance push',
        'status': 'IN_PROGRESS',
        'programId': 'program-1',
        'startedAt': '2026-07-20T10:00:00.000Z',
        'endedAt': '2026-07-20T11:00:00.000Z',
        'sets': [
          {
            'id': 'set-1',
            'exerciseId': 'ex-1',
            'setOrder': 1,
            'reps': 10,
            'weightKg': 50.0,
            'restSeconds': 90,
            'isWarmup': false,
          },
        ],
        'plannedExercises': [
          {
            'id': 'planned-1',
            'exerciseId': 'ex-1',
            'exerciseOrder': 1,
            'sets': [
              {'id': 'planned-set-1', 'setOrder': 1, 'targetReps': 10},
            ],
          },
        ],
      });

      expect(session.id, 'session-1');
      expect(session.name, 'Séance push');
      expect(session.status, 'IN_PROGRESS');
      expect(session.programId, 'program-1');
      expect(session.startedAt, DateTime.parse('2026-07-20T10:00:00.000Z'));
      expect(session.endedAt, DateTime.parse('2026-07-20T11:00:00.000Z'));
      expect(session.sets, hasLength(1));
      expect(session.plannedExercises, hasLength(1));
    });

    test('defaults sets and plannedExercises to empty lists when absent', () {
      final session = TrainingSession.fromJson({
        'id': 'session-2',
        'status': 'DONE',
        'startedAt': '2026-07-20T10:00:00.000Z',
      });

      expect(session.sets, isEmpty);
      expect(session.plannedExercises, isEmpty);
      expect(session.endedAt, isNull);
      expect(session.name, isNull);
      expect(session.programId, isNull);
    });
  });

  group('ExerciseSet.fromJson', () {
    test('parses all fields', () {
      final set = ExerciseSet.fromJson({
        'id': 'set-1',
        'exerciseId': 'ex-1',
        'setOrder': 2,
        'reps': 8,
        'weightKg': 75.5,
        'restSeconds': 60,
        'isWarmup': true,
      });

      expect(set.id, 'set-1');
      expect(set.exerciseId, 'ex-1');
      expect(set.setOrder, 2);
      expect(set.reps, 8);
      expect(set.weightKg, 75.5);
      expect(set.restSeconds, 60);
      expect(set.isWarmup, isTrue);
    });

    test('isWarmup defaults to false when absent', () {
      final set = ExerciseSet.fromJson({
        'id': 'set-2',
        'exerciseId': 'ex-1',
        'setOrder': 1,
      });

      expect(set.isWarmup, isFalse);
    });
  });

  group('SessionPlannedSet.fromJson', () {
    test('reads weight from the "targetWeightKg" JSON key', () {
      final plannedSet = SessionPlannedSet.fromJson({
        'id': 'planned-set-1',
        'setOrder': 1,
        'targetReps': 10,
        'targetWeightKg': 40.0,
        'restSeconds': 90,
      });

      expect(plannedSet.targetWeight, 40.0);
    });

    test('targetWeight is null when key absent', () {
      final plannedSet = SessionPlannedSet.fromJson({
        'id': 'planned-set-2',
        'setOrder': 1,
      });

      expect(plannedSet.targetWeight, isNull);
      expect(plannedSet.isWarmup, isFalse);
    });
  });

  group('SessionPlannedExercise.fromJson', () {
    test('defaults sets to an empty list when absent', () {
      final plannedExercise = SessionPlannedExercise.fromJson({
        'id': 'planned-1',
        'exerciseId': 'ex-1',
        'exerciseOrder': 1,
      });

      expect(plannedExercise.sets, isEmpty);
    });
  });
}
