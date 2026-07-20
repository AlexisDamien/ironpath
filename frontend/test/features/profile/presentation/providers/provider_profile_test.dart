import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ironpath/features/profile/domain/models/profile_input.dart';
import 'package:ironpath/features/profile/domain/state_profile.dart';
import 'package:ironpath/features/profile/presentation/providers/provider_profile.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockRepositoryProfile repository;
  late ProviderProfileNotifier notifier;

  setUp(() {
    repository = MockRepositoryProfile();
    notifier = ProviderProfileNotifier(repository);
  });

  tearDown(() => notifier.dispose());

  test('loadProfile charge un profil', () async {
    final profile = profileFixture();
    when(() => repository.getProfile()).thenAnswer((_) async => profile);

    await notifier.loadProfile();

    expect(notifier.state.status, StatusProfile.success);
    expect(notifier.state.profile, same(profile));
    expect(notifier.state.errorMessage, isNull);
  });

  test('loadProfile accepte une absence de profil', () async {
    when(() => repository.getProfile()).thenAnswer((_) async => null);

    await notifier.loadProfile();

    expect(notifier.state.status, StatusProfile.success);
    expect(notifier.state.profile, isNull);
  });

  test('loadProfile expose une erreur formatée', () async {
    when(() => repository.getProfile()).thenThrow(Exception('offline'));

    await notifier.loadProfile();

    expect(notifier.state.status, StatusProfile.error);
    expect(notifier.state.errorMessage, 'offline');
  });

  test('updateProfile remplace le profil', () async {
    const input = ProfileInput(firstName: 'Nouveau');
    final updated = profileFixture(id: 'updated');
    when(() => repository.updateProfile(input))
        .thenAnswer((_) async => updated);

    final result = await notifier.updateProfile(input);

    expect(result, same(updated));
    expect(notifier.state.status, StatusProfile.success);
    expect(notifier.state.profile, same(updated));
  });

  test('updateProfile restaure l’ancien profil en cas d’erreur', () async {
    final oldProfile = profileFixture(id: 'old');
    when(() => repository.getProfile()).thenAnswer((_) async => oldProfile);
    await notifier.loadProfile();

    const input = ProfileInput(firstName: 'Nouveau');
    when(() => repository.updateProfile(input)).thenThrow(Exception('refusé'));

    await expectLater(
      notifier.updateProfile(input),
      throwsA(isA<Exception>()),
    );

    expect(notifier.state.status, StatusProfile.success);
    expect(notifier.state.profile, same(oldProfile));
    expect(notifier.state.errorMessage, 'refusé');
  });

  test('reset remet l’état initial', () async {
    when(() => repository.getProfile())
        .thenAnswer((_) async => profileFixture());
    await notifier.loadProfile();

    notifier.reset();

    expect(notifier.state.status, StatusProfile.idle);
    expect(notifier.state.profile, isNull);
  });
}
