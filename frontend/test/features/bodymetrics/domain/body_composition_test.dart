import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/bodymetrics/domain/models/body_composition.dart';

import '../../../helpers/fixtures.dart';

void main() {
  test('fromJson convertit les données de composition', () {
    final composition = BodyComposition.fromJson(compositionJson());

    expect(composition.bodyFat, 15.2);
    expect(composition.visceralFat, 7);
    expect(composition.bmr, 1820);
    expect(composition.bmi, 25.9);
    expect(composition.isManual, isTrue);
    expect(composition.isEditable, isTrue);
  });

  test('une mesure importée n’est pas manuelle', () {
    expect(compositionFixture(source: 'DEVICE').isManual, isFalse);
  });

  test('une composition archivée n’est pas modifiable', () {
    expect(compositionFixture(archived: true).isEditable, isFalse);
  });

  test('source et archived ont des valeurs par défaut', () {
    final json = compositionJson()
      ..remove('source')
      ..remove('archived');
    final composition = BodyComposition.fromJson(json);

    expect(composition.source, 'MANUAL');
    expect(composition.archived, isFalse);
  });
}
