import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/bodymetrics/presentation/providers/provider_bodymetrics.dart';
import 'package:ironpath/features/bodymetrics/presentation/widgets/form_measurement.dart';
import 'package:ironpath/features/profile/presentation/providers/provider_profile.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockRepositoryBodyMetrics bodyMetricsRepository;
  late MockRepositoryProfile profileRepository;

  setUp(() {
    bodyMetricsRepository = MockRepositoryBodyMetrics();
    profileRepository = MockRepositoryProfile();
  });

  Future<void> pumpForm(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerBodyMetricsRepository.overrideWithValue(
            bodyMetricsRepository,
          ),
          providerProfileRepository.overrideWithValue(profileRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: FormMeasurement()),
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
        'Les champs de mesure sont facultatifs, mais toute valeur saisie doit être numérique et positive.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('refuse une valeur non numérique', (tester) async {
    await pumpForm(tester);

    final weightField = find.byType(TextFormField).first;
    await tester.enterText(weightField, 'abc');
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pump();

    expect(
      find.text('Saisissez un nombre valide pour Poids (kg)'),
      findsOneWidget,
    );
  });

  testWidgets('refuse une valeur négative', (tester) async {
    await pumpForm(tester);

    final weightField = find.byType(TextFormField).first;
    await tester.enterText(weightField, '-1');
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pump();

    expect(
      find.text('Poids (kg) ne peut pas être négatif'),
      findsOneWidget,
    );
  });
}
