import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/bodymetrics/domain/state_bodymetrics.dart';

import '../../../helpers/fixtures.dart';

void main() {
  test('copyWith met à jour les collections et le statut', () {
    const state = StateBodyMetrics();
    final measurement = measurementFixture();
    final composition = compositionFixture();

    final copy = state.copyWith(
      status: StatusBodyMetrics.success,
      measurements: [measurement],
      compositions: [composition],
      isInitialized: true,
    );

    expect(copy.status, StatusBodyMetrics.success);
    expect(copy.measurements, [measurement]);
    expect(copy.compositions, [composition]);
    expect(copy.isInitialized, isTrue);
  });

  test('clearErrorMessage efface l’erreur', () {
    const state = StateBodyMetrics(errorMessage: 'Erreur');
    expect(state.copyWith(clearErrorMessage: true).errorMessage, isNull);
  });
}
