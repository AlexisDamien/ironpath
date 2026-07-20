import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/bodymetrics/domain/models/body_measurement.dart';

import '../../../helpers/fixtures.dart';

void main() {
  test('fromJson convertit les nombres en double', () {
    final measurement = BodyMeasurement.fromJson(measurementJson());

    expect(measurement.id, 'measurement-1');
    expect(measurement.weight, 82.0);
    expect(measurement.chest, 101.5);
    expect(measurement.recordedAt, DateTime.parse('2026-07-20T08:30:00.000Z'));
    expect(measurement.notes, 'Matin');
    expect(measurement.isEditable, isTrue);
  });

  test('une mesure archivée n’est pas modifiable', () {
    expect(measurementFixture(archived: true).isEditable, isFalse);
  });

  test('archived vaut false par défaut', () {
    final json = measurementJson()..remove('archived');
    expect(BodyMeasurement.fromJson(json).archived, isFalse);
  });
}
