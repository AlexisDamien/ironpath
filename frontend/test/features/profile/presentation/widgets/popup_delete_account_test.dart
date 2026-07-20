import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ironpath/features/identity/presentation/providers/provider_identity.dart';
import 'package:ironpath/features/profile/presentation/providers/provider_profile.dart';
import 'package:ironpath/features/profile/presentation/widgets/popup_delete_account.dart';

import '../../../../helpers/mocks.dart';

class _DeleteHarness extends ConsumerStatefulWidget {
  const _DeleteHarness();

  @override
  ConsumerState<_DeleteHarness> createState() => _DeleteHarnessState();
}

class _DeleteHarnessState extends ConsumerState<_DeleteHarness> {
  bool? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              result = await showDeleteAccountDialog(context, ref);
              setState(() {});
            },
            child: const Text('Ouvrir suppression'),
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
        child: const MaterialApp(home: _DeleteHarness()),
      );

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    await tester.tap(find.text('Ouvrir suppression'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('exige le mot de passe et la confirmation', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('Supprimer définitivement le compte'));
    await tester.pump();

    expect(find.text('Saisissez votre mot de passe actuel'), findsOneWidget);
    expect(
      find.text(
        'Confirmez que vous comprenez le caractère irréversible de la suppression.',
      ),
      findsOneWidget,
    );
    verifyNever(
      () => identityRepository.deleteAccount(
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('supprime et ferme proprement après confirmation',
      (tester) async {
    when(
      () => identityRepository.deleteAccount(password: 'MotDePasse12!'),
    ).thenAnswer((_) async {});
    await openDialog(tester);

    await tester.enterText(find.byType(TextFormField), 'MotDePasse12!');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.text('Supprimer définitivement le compte'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Résultat: true'), findsOneWidget);
    verify(
      () => identityRepository.deleteAccount(password: 'MotDePasse12!'),
    ).called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('une erreur serveur reste dans la modale', (tester) async {
    when(
      () => identityRepository.deleteAccount(password: 'MotDePasse12!'),
    ).thenThrow(Exception('Mot de passe incorrect'));
    await openDialog(tester);

    await tester.enterText(find.byType(TextFormField), 'MotDePasse12!');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.text('Supprimer définitivement le compte'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Mot de passe incorrect'), findsOneWidget);
    expect(find.text('Supprimer le compte'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
