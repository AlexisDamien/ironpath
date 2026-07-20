import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ironpath/features/identity/presentation/providers/provider_identity.dart';
import 'package:ironpath/features/identity/presentation/widgets/popup_forgot_password.dart';
import 'package:ironpath/features/profile/presentation/providers/provider_profile.dart';

import '../../../../helpers/mocks.dart';

class _DialogHarness extends ConsumerStatefulWidget {
  const _DialogHarness();

  @override
  ConsumerState<_DialogHarness> createState() => _DialogHarnessState();
}

class _DialogHarnessState extends ConsumerState<_DialogHarness> {
  bool? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              result = await showForgotPasswordDialog(
                context,
                ref,
                initialEmail: 'alex@example.com',
              );
              setState(() {});
            },
            child: const Text('Ouvrir'),
          ),
          Text('Résultat: $result'),
        ],
      ),
    );
  }
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

  Widget app() => ProviderScope(
        overrides: [
          providerIdentityRepository.overrideWithValue(identityRepository),
          providerProfileRepository.overrideWithValue(profileRepository),
        ],
        child: const MaterialApp(home: _DialogHarness()),
      );

  testWidgets('préremplit l’email et ferme avec true après succès',
      (tester) async {
    when(
      () => identityRepository.requestPasswordReset(
        email: 'alex@example.com',
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    await tester.tap(find.text('Ouvrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller?.text, 'alex@example.com');

    await tester.tap(find.text('Envoyer le lien de réinitialisation'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Résultat: true'), findsOneWidget);
    verify(
      () => identityRepository.requestPasswordReset(
        email: 'alex@example.com',
      ),
    ).called(1);
  });

  testWidgets('la croix ferme avec false sans envoyer', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    await tester.tap(find.text('Ouvrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip('Annuler et fermer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Résultat: false'), findsOneWidget);
    verifyNever(
      () => identityRepository.requestPasswordReset(
        email: any(named: 'email'),
      ),
    );
  });

  testWidgets('affiche une erreur sans fermer la modale', (tester) async {
    when(
      () => identityRepository.requestPasswordReset(
        email: 'alex@example.com',
      ),
    ).thenThrow(Exception('Service indisponible'));

    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    await tester.tap(find.text('Ouvrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Envoyer le lien de réinitialisation'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Service indisponible'), findsOneWidget);
    expect(find.text('Mot de passe oublié'), findsOneWidget);
  });
}
