import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/core/constants/legal_texts.dart';

void main() {
  test('les CGU contiennent les sections essentielles', () {
    expect(LegalTexts.cgu, contains('CONDITIONS GÉNÉRALES'));
    expect(LegalTexts.cgu, contains('Résiliation'));
    expect(LegalTexts.cgu, contains('supprimer votre compte'));
  });

  test('la politique RGPD décrit les droits utilisateur', () {
    expect(LegalTexts.rgpd, contains('RGPD'));
    expect(LegalTexts.rgpd, contains("Droit d'accès"));
    expect(LegalTexts.rgpd, contains("Droit à l'effacement"));
  });
}
