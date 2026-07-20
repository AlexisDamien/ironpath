import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/core/utils/format_profile.dart';

void main() {
  group('formatProfileDisplayName', () {
    test('préfère le prénom et le nom', () {
      expect(
        formatProfileDisplayName(
          firstName: ' Alex ',
          lastName: ' Martin ',
          username: 'alexm',
        ),
        'Alex Martin',
      );
    });

    test('utilise le username lorsque le nom est absent', () {
      expect(formatProfileDisplayName(username: ' alexm '), 'alexm');
    });

    test('utilise Utilisateur en dernier recours', () {
      expect(formatProfileDisplayName(), 'Utilisateur');
    });
  });

  test('formatGender traduit les valeurs connues', () {
    expect(formatGender('MALE'), 'Homme');
    expect(formatGender('FEMALE'), 'Femme');
    expect(formatGender('OTHER'), 'Autre');
    expect(formatGender('UNKNOWN'), 'Non renseigné');
    expect(formatGender(null), 'Non renseigné');
  });

  test('formatObjective traduit les valeurs connues', () {
    expect(formatObjective('MUSCLE_GAIN'), 'Prise de masse');
    expect(formatObjective('WEIGHT_LOSS'), 'Perte de poids');
    expect(formatObjective('MAINTENANCE'), 'Maintien');
    expect(formatObjective('ENDURANCE'), 'Endurance');
    expect(formatObjective('STRENGTH'), 'Force');
    expect(formatObjective(null), 'Non renseigné');
  });
}
