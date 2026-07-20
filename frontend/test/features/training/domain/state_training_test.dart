import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/state_training.dart';

import '../../../helpers/fixtures.dart';

void main() {
  test('copyWith met à jour les données', () {
    const state = StateTraining();
    final program = programFixture();
    final session = sessionFixture();
    final exercise = exerciseFixture();

    final copy = state.copyWith(
      status: StatusTraining.success,
      programs: [program],
      activeSession: session,
      sessionHistory: [session],
      exercises: [exercise],
    );

    expect(copy.status, StatusTraining.success);
    expect(copy.programs, [program]);
    expect(copy.activeSession, same(session));
    expect(copy.sessionHistory, [session]);
    expect(copy.exercises, [exercise]);
  });

  test('clearActiveSession et clearErrorMessage effacent les valeurs', () {
    final state = StateTraining(
      activeSession: sessionFixture(),
      errorMessage: 'Erreur',
    );

    final copy = state.copyWith(
      clearActiveSession: true,
      clearErrorMessage: true,
    );

    expect(copy.activeSession, isNull);
    expect(copy.errorMessage, isNull);
  });
}
