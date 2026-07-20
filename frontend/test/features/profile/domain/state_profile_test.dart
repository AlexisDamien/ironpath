import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/profile/domain/state_profile.dart';

import '../../../helpers/fixtures.dart';

void main() {
  test('copyWith peut remplacer et effacer le profil', () {
    const initial = StateProfile();
    final profile = profileFixture();

    final loaded = initial.copyWith(
      status: StatusProfile.success,
      profile: profile,
    );
    expect(loaded.profile, same(profile));

    final cleared = loaded.copyWith(clearProfile: true);
    expect(cleared.profile, isNull);
  });

  test('copyWith peut effacer l’erreur', () {
    const state = StateProfile(errorMessage: 'Erreur');
    expect(state.copyWith(clearErrorMessage: true).errorMessage, isNull);
  });
}
