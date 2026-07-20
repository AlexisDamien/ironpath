import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ironpath/features/identity/domain/state_identity.dart';
import 'package:ironpath/features/identity/presentation/providers/provider_identity.dart';
import 'package:ironpath/features/profile/domain/state_profile.dart';
import 'package:ironpath/features/profile/presentation/providers/provider_profile.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

Future<void> flushProvider() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  late MockRepositoryIdentity identityRepository;
  late MockRepositoryProfile profileRepository;
  late ProviderContainer container;

  setUp(() {
    identityRepository = MockRepositoryIdentity();
    profileRepository = MockRepositoryProfile();

    when(() => identityRepository.restoreSession())
        .thenAnswer((_) async => null);

    container = ProviderContainer(
      overrides: [
        providerIdentityRepository.overrideWithValue(identityRepository),
        providerProfileRepository.overrideWithValue(profileRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('restaure vers unauthenticated lorsqu’aucune session n’existe',
      () async {
    container.read(providerIdentity);
    await flushProvider();

    final state = container.read(providerIdentity);
    expect(state.status, StatusAuth.unauthenticated);
    expect(state.isRestoringSession, isFalse);
  });

  test('restaure une session et charge le profil', () async {
    container.dispose();
    when(() => identityRepository.restoreSession())
        .thenAnswer((_) async => true);
    when(() => profileRepository.getProfile())
        .thenAnswer((_) async => profileFixture());
    container = ProviderContainer(
      overrides: [
        providerIdentityRepository.overrideWithValue(identityRepository),
        providerProfileRepository.overrideWithValue(profileRepository),
      ],
    );

    container.read(providerIdentity);
    await flushProvider();
    await flushProvider();

    final state = container.read(providerIdentity);
    expect(state.status, StatusAuth.authenticated);
    expect(state.isEmailVerified, isTrue);
    expect(container.read(providerProfile).status, StatusProfile.success);
  });

  test('login réussi authentifie et charge le profil', () async {
    container.read(providerIdentity);
    await flushProvider();
    when(
      () => identityRepository.login(
        email: 'alex@example.com',
        password: 'MotDePasse12!',
        rememberMe: true,
      ),
    ).thenAnswer((_) async => false);
    when(() => profileRepository.getProfile())
        .thenAnswer((_) async => profileFixture());

    await container.read(providerIdentity.notifier).login(
          'alex@example.com',
          'MotDePasse12!',
          rememberMe: true,
        );

    final state = container.read(providerIdentity);
    expect(state.status, StatusAuth.authenticated);
    expect(state.isEmailVerified, isFalse);
    expect(container.read(providerProfile).profile, isNotNull);
  });

  test('login échoué rend le champ réutilisable via un état unauthenticated',
      () async {
    container.read(providerIdentity);
    await flushProvider();
    when(
      () => identityRepository.login(
        email: 'alex@example.com',
        password: 'mauvais',
        rememberMe: false,
      ),
    ).thenThrow(Exception('Identifiants invalides'));

    await container.read(providerIdentity.notifier).login(
          'alex@example.com',
          'mauvais',
          rememberMe: false,
        );

    final state = container.read(providerIdentity);
    expect(state.status, StatusAuth.unauthenticated);
    expect(state.errorMessage, 'Identifiants invalides');
    expect(state.isRestoringSession, isFalse);
  });

  test('clearError efface le message', () async {
    container.read(providerIdentity);
    await flushProvider();
    when(
      () => identityRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
        rememberMe: any(named: 'rememberMe'),
      ),
    ).thenThrow(Exception('Erreur'));

    await container.read(providerIdentity.notifier).login(
          'a@b.fr',
          'bad',
          rememberMe: false,
        );
    container.read(providerIdentity.notifier).clearError();

    expect(container.read(providerIdentity).errorMessage, isNull);
  });

  test('register authentifie le nouvel utilisateur', () async {
    container.read(providerIdentity);
    await flushProvider();
    when(
      () => identityRepository.register(
        email: 'alex@example.com',
        password: 'MotDePasse12!',
        rgpdConsent: true,
      ),
    ).thenAnswer((_) async => false);
    when(() => profileRepository.getProfile()).thenAnswer((_) async => null);

    await container.read(providerIdentity.notifier).register(
          'alex@example.com',
          'MotDePasse12!',
        );

    expect(container.read(providerIdentity).status, StatusAuth.authenticated);
  });

  test('logout termine toujours en unauthenticated', () async {
    container.read(providerIdentity);
    await flushProvider();
    when(() => identityRepository.logout()).thenThrow(Exception('offline'));

    await expectLater(
      container.read(providerIdentity.notifier).logout(),
      throwsA(isA<Exception>()),
    );

    expect(container.read(providerIdentity).status, StatusAuth.unauthenticated);
    expect(container.read(providerProfile).profile, isNull);
  });

  test('requestPasswordReset propage une erreur lisible', () async {
    container.read(providerIdentity);
    await flushProvider();
    when(
      () => identityRepository.requestPasswordReset(
        email: 'alex@example.com',
      ),
    ).thenThrow(Exception('SMTP indisponible'));

    await expectLater(
      container
          .read(providerIdentity.notifier)
          .requestPasswordReset(email: 'alex@example.com'),
      throwsA(
        predicate<Object>(
          (error) => error.toString().contains('SMTP indisponible'),
        ),
      ),
    );
  });

  test('refreshEmailVerificationStatus met à jour le drapeau', () async {
    container.read(providerIdentity);
    await flushProvider();
    when(() => identityRepository.checkEmailVerificationStatus())
        .thenAnswer((_) async => true);

    await container
        .read(providerIdentity.notifier)
        .refreshEmailVerificationStatus();

    expect(container.read(providerIdentity).isEmailVerified, isTrue);
  });

  test('changePassword délègue au repository', () async {
    container.read(providerIdentity);
    await flushProvider();
    when(
      () => identityRepository.changePassword(
        currentPassword: 'Ancien12!',
        newPassword: 'NouveauPass12!',
      ),
    ).thenAnswer((_) async {});

    await container.read(providerIdentity.notifier).changePassword(
          currentPassword: 'Ancien12!',
          newPassword: 'NouveauPass12!',
        );

    verify(
      () => identityRepository.changePassword(
        currentPassword: 'Ancien12!',
        newPassword: 'NouveauPass12!',
      ),
    ).called(1);
  });

  test('deleteAccount délègue au repository', () async {
    container.read(providerIdentity);
    await flushProvider();
    when(
      () => identityRepository.deleteAccount(password: 'MotDePasse12!'),
    ).thenAnswer((_) async {});

    await container
        .read(providerIdentity.notifier)
        .deleteAccount(password: 'MotDePasse12!');

    verify(
      () => identityRepository.deleteAccount(password: 'MotDePasse12!'),
    ).called(1);
  });

  test('resendVerificationEmail délègue au repository', () async {
    container.read(providerIdentity);
    await flushProvider();
    when(() => identityRepository.resendVerificationEmail())
        .thenAnswer((_) async {});

    await container.read(providerIdentity.notifier).resendVerificationEmail();

    verify(() => identityRepository.resendVerificationEmail()).called(1);
  });

  test('completeAccountDeletion réinitialise identité et profil', () async {
    container.read(providerIdentity);
    await flushProvider();
    when(() => profileRepository.getProfile())
        .thenAnswer((_) async => profileFixture());
    await container.read(providerProfile.notifier).loadProfile();

    container.read(providerIdentity.notifier).completeAccountDeletion();

    expect(container.read(providerIdentity).status, StatusAuth.unauthenticated);
    expect(container.read(providerProfile).profile, isNull);
  });
}
