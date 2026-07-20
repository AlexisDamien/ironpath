import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/bodymetrics/presentation/providers/provider_bodymetrics.dart';
import 'package:ironpath/features/bodymetrics/presentation/widgets/form_composition.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockRepositoryBodyMetrics repository;

  setUp(() {
    repository = MockRepositoryBodyMetrics();
  });

  Future<void> pumpForm(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerBodyMetricsRepository.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: FormComposition()),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('affiche le récapitulatif des contraintes en pied de formulaire',
      (tester) async {
    await pumpForm(tester);

    expect(
      find.text(
        'Les champs sont facultatifs, mais toute valeur saisie doit être numérique et positive.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('refuse une valeur décimale invalide', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).first, 'invalide');
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pump();

    expect(
      find.text('Saisissez un nombre valide pour Masse grasse (%)'),
      findsOneWidget,
    );
  });

  testWidgets('refuse un entier invalide pour la graisse viscérale',
      (tester) async {
    await pumpForm(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(4), '2.5');
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pump();

    expect(
      find.text('Saisissez un nombre entier pour Graisse viscérale'),
      findsOneWidget,
    );
  });

  testWidgets('refuse une valeur négative', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).first, '-5');
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pump();

    expect(
      find.text('Masse grasse (%) ne peut pas être négatif'),
      findsOneWidget,
    );
  });
}
