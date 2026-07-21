import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/bodymetrics/domain/models/body_composition.dart';

void main() {
  group('BodyComposition.fromJson', () {
    test('parses all fields when fully populated', () {
      final composition = BodyComposition.fromJson({
        'id': 'bc-1',
        'bodyFat': 15.5,
        'skeletalMuscle': 40.2,
        'fatFreeMass': 65.0,
        'subcutaneousFat': 12.1,
        'visceralFat': 5,
        'bodyWater': 55.0,
        'muscleMass': 38.0,
        'boneMass': 3.2,
        'protein': 18.0,
        'bmr': 1800,
        'bmi': 22.5,
        'metabolicAge': 28,
        'notes': 'Mesure du matin',
        'recordedAt': '2026-07-20T08:00:00.000Z',
        'source': 'DEVICE',
        'archived': true,
      });

      expect(composition.id, 'bc-1');
      expect(composition.bodyFat, 15.5);
      expect(composition.visceralFat, 5);
      expect(composition.bmr, 1800);
      expect(composition.metabolicAge, 28);
      expect(composition.notes, 'Mesure du matin');
      expect(composition.source, 'DEVICE');
      expect(composition.archived, isTrue);
    });

    test('defaults source to MANUAL and archived to false', () {
      final composition = BodyComposition.fromJson({
        'id': 'bc-2',
        'recordedAt': '2026-07-20T08:00:00.000Z',
      });

      expect(composition.source, 'MANUAL');
      expect(composition.archived, isFalse);
      expect(composition.bodyFat, isNull);
    });
  });

  group('BodyComposition getters', () {
    test('isEditable is true when not archived', () {
      final composition = BodyComposition(
        id: 'bc-1',
        recordedAt: DateTime(2026, 7, 20),
        archived: false,
      );

      expect(composition.isEditable, isTrue);
    });

    test('isEditable is false when archived', () {
      final composition = BodyComposition(
        id: 'bc-1',
        recordedAt: DateTime(2026, 7, 20),
        archived: true,
      );

      expect(composition.isEditable, isFalse);
    });

    test('isManual is true when source is MANUAL (default)', () {
      final composition = BodyComposition(
        id: 'bc-1',
        recordedAt: DateTime(2026, 7, 20),
      );

      expect(composition.isManual, isTrue);
    });

    test('isManual is false when source is DEVICE', () {
      final composition = BodyComposition(
        id: 'bc-1',
        recordedAt: DateTime(2026, 7, 20),
        source: 'DEVICE',
      );

      expect(composition.isManual, isFalse);
    });
  });
}
