import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/identity/domain/state_identity.dart';

void main() {
  test('les valeurs par défaut sont cohérentes', () {
    const state = StateIdentity();

    expect(state.status, StatusAuth.initial);
    expect(state.errorMessage, isNull);
    expect(state.isEmailVerified, isFalse);
    expect(state.isRestoringSession, isFalse);
  });

  test('copyWith conserve les valeurs non modifiées', () {
    const state = StateIdentity(
      status: StatusAuth.authenticated,
      errorMessage: 'Erreur',
      userId: 'user-1',
      isEmailVerified: true,
    );

    final copy = state.copyWith(status: StatusAuth.loading);

    expect(copy.status, StatusAuth.loading);
    expect(copy.errorMessage, 'Erreur');
    expect(copy.userId, 'user-1');
    expect(copy.isEmailVerified, isTrue);
  });

  test('clearErrorMessage efface explicitement l’erreur', () {
    const state = StateIdentity(errorMessage: 'Erreur');
    expect(state.copyWith(clearErrorMessage: true).errorMessage, isNull);
  });
}
