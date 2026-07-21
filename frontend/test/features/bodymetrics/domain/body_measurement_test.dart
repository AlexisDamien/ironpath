import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/bodymetrics/domain/models/body_measurement.dart';

void main() {
  group('BodyMeasurement.fromJson', () {
    test('parses all fields when fully populated', () {
      final measurement = BodyMeasurement.fromJson({
        'id': 'bm-1',
        'weight': 80.5,
        'chest': 100.0,
        'waist': 85.0,
        'hips': 95.0,
        'leftArm': 35.0,
        'rightArm': 35.5,
        'leftThigh': 55.0,
        'rightThigh': 55.5,
        'leftCalf': 38.0,
        'rightCalf': 38.5,
        'notes': 'Après entraînement',
        'recordedAt': '2026-07-20T08:00:00.000Z',
        'archived': false,
      });

      expect(measurement.id, 'bm-1');
      expect(measurement.weight, 80.5);
      expect(measurement.chest, 100.0);
      expect(measurement.notes, 'Après entraînement');
      expect(measurement.archived, isFalse);
    });

    test('defaults archived to false and nullable fields to null', () {
      final measurement = BodyMeasurement.fromJson({
        'id': 'bm-2',
        'recordedAt': '2026-07-20T08:00:00.000Z',
      });

      expect(measurement.archived, isFalse);
      expect(measurement.weight, isNull);
      expect(measurement.notes, isNull);
    });
  });

  group('BodyMeasurement getters', () {
    test('isEditable is true when not archived', () {
      final measurement = BodyMeasurement(
        id: 'bm-1',
        recordedAt: DateTime(2026, 7, 20),
        archived: false,
      );

      expect(measurement.isEditable, isTrue);
    });

    test('isEditable is false when archived', () {
      final measurement = BodyMeasurement(
        id: 'bm-1',
        recordedAt: DateTime(2026, 7, 20),
        archived: true,
      );

      expect(measurement.isEditable, isFalse);
    });
  });
}
