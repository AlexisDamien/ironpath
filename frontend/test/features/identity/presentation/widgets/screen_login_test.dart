import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ironpath/features/identity/presentation/providers/provider_identity.dart';
import 'package:ironpath/features/identity/presentation/screens/screen_login.dart';
import 'package:ironpath/features/profile/presentation/providers/provider_profile.dart';

import '../../../../helpers/mocks.dart';

Future<void> _tapLoginButton(WidgetTester tester) async {
  final loginButton = find.widgetWithText(ElevatedButton, 'Se connecter');
  expect(loginButton, findsOneWidget);

  await tester.ensureVisible(loginButton);
  await tester.pumpAndSettle();
  await tester.tap(loginButton);
  await tester.pumpAndSettle();
}

void main() {
  late MockRepositoryIdentity identityRepository;
  late MockRepositoryProfile profileRepository;

  setUp(() {
    identityRepository = MockRepositoryIdentity();
    profileRepository = MockRepositoryProfile();
    when(() => identityRepository.restoreSession())
        .thenAnswer((_) async => null);
  });

  testWidgets('le champ mot de passe reste éditable après une erreur',
      (tester) async {
    when(
      () => identityRepository.login(
        email: 'alex@example.com',
        password: 'mauvais',
        rememberMe: true,
      ),
    ).thenThrow(Exception('Identifiants invalides'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerIdentityRepository.overrideWithValue(identityRepository),
          providerProfileRepository.overrideWithValue(profileRepository),
        ],
        child: const MaterialApp(home: ScreenLogin()),
      ),
    );
    await tester.pumpAndSettle();

    final emailField = find.widgetWithText(TextFormField, 'Adresse email *');
    final passwordField = find.widgetWithText(TextFormField, 'Mot de passe *');
    await tester.enterText(emailField, 'alex@example.com');
    await tester.enterText(passwordField, 'mauvais');
    await _tapLoginButton(tester);

    expect(find.text('Identifiants invalides'), findsOneWidget);

    final passwordEditableText = find.descendant(
      of: passwordField,
      matching: find.byType(EditableText),
    );
    expect(passwordEditableText, findsOneWidget);
    expect(
      tester.widget<EditableText>(passwordEditableText).readOnly,
      isFalse,
    );

    await tester.enterText(passwordField, 'nouveau mot de passe');
    await tester.pump();
    expect(
      tester.widget<EditableText>(passwordEditableText).controller.text,
      'nouveau mot de passe',
    );
  });

  testWidgets('valide les champs obligatoires', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerIdentityRepository.overrideWithValue(identityRepository),
          providerProfileRepository.overrideWithValue(profileRepository),
        ],
        child: const MaterialApp(home: ScreenLogin()),
      ),
    );
    await tester.pumpAndSettle();

    await _tapLoginButton(tester);

    expect(find.text('Saisissez votre adresse email'), findsOneWidget);
    expect(find.text('Saisissez votre mot de passe'), findsOneWidget);
  });

  testWidgets('affiche les options de session et de récupération',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerIdentityRepository.overrideWithValue(identityRepository),
          providerProfileRepository.overrideWithValue(profileRepository),
        ],
        child: const MaterialApp(home: ScreenLogin()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Se souvenir de moi'), findsOneWidget);
    expect(find.text('Mot de passe oublié ?'), findsOneWidget);
    expect(find.bySemanticsLabel('Logo IronPath'), findsOneWidget);
  });
}
