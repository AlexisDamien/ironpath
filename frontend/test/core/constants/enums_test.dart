import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/core/constants/enums.dart';

void main() {
  test('UnitSystem expose les unités métriques', () {
    expect(UnitSystem.metric.lengthUnit, 'cm');
    expect(UnitSystem.metric.weightUnit, 'kg');
  });

  test('UnitSystem expose les unités impériales', () {
    expect(UnitSystem.imperial.lengthUnit, 'in');
    expect(UnitSystem.imperial.weightUnit, 'lbs');
  });

  test('les statuts contiennent les états attendus', () {
    expect(StatusAuth.values, contains(StatusAuth.authenticated));
    expect(StatusProfile.values, contains(StatusProfile.success));
    expect(StatusBodyMetrics.values, contains(StatusBodyMetrics.error));
    expect(StatusTraining.values, contains(StatusTraining.loading));
  });
}
