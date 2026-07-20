import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/models/training_session.dart';

import '../../../helpers/fixtures.dart';

void main() {
  test('TrainingSession.fromJson convertit toute la séance', () {
    final session = TrainingSession.fromJson(sessionJson());

    expect(session.id, 'session-1');
    expect(session.status, 'IN_PROGRESS');
    expect(session.endedAt, isNull);
    expect(session.sets, hasLength(1));
    expect(session.sets.single.weightKg, 80.0);
    expect(session.plannedExercises, hasLength(1));
    expect(session.plannedExercises.single.sets.single.targetWeight, 80.0);
  });

  test('convertit la date de fin quand elle existe', () {
    final session = TrainingSession.fromJson(
      sessionJson(status: 'COMPLETED'),
    );

    expect(session.endedAt, DateTime.parse('2026-07-20T09:00:00.000Z'));
  });

  test('les listes absentes deviennent vides', () {
    final json = sessionJson()
      ..remove('sets')
      ..remove('plannedExercises');
    final session = TrainingSession.fromJson(json);

    expect(session.sets, isEmpty);
    expect(session.plannedExercises, isEmpty);
  });
}
