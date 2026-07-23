import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/bodymetrics/domain/models/body_measurement.dart';
import 'package:ironpath/features/bodymetrics/presentation/providers/provider_bodymetrics.dart';
import 'package:ironpath/features/bodymetrics/presentation/widgets/form_measurement.dart';
import 'package:ironpath/features/profile/data/repository_profile.dart';
import 'package:ironpath/features/profile/domain/models/profile.dart';
import 'package:ironpath/features/profile/domain/state_profile.dart';
import 'package:ironpath/features/profile/presentation/providers/provider_profile.dart';

import '../../../../helpers/mocks.dart';

class _FakeProfileNotifier extends ProviderProfileNotifier {
  _FakeProfileNotifier(StateProfile initialState, RepositoryProfile repository)
      : super(repository) {
    state = initialState;
  }
}

void main() {
  late MockRepositoryBodyMetrics bodyMetricsRepository;
  late MockRepositoryProfile profileRepository;

  setUp(() {
    bodyMetricsRepository = MockRepositoryBodyMetrics();
    profileRepository = MockRepositoryProfile();
  });

  Future<void> pumpForm(
    WidgetTester tester, {
    BodyMeasurement? measurementToEdit,
    double? profileHeight,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerBodyMetricsRepository.overrideWithValue(
            bodyMetricsRepository,
          ),
          providerProfileRepository.overrideWithValue(profileRepository),
          if (profileHeight != null)
            providerProfile.overrideWith(
              (ref) => _FakeProfileNotifier(
                StateProfile(
                  profile: Profile(id: 'user-1', height: profileHeight),
                ),
                profileRepository,
              ),
            ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FormMeasurement(measurementToEdit: measurementToEdit),
          ),
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

  testWidgets(
      'pré-remplit la taille depuis le profil à la création d\'une mesure',
      (tester) async {
    await pumpForm(tester, profileHeight: 180.0);

    final heightField = tester.widget<TextFormField>(
      find.ancestor(
        of: find.text('Taille (cm)'),
        matching: find.byType(TextFormField),
      ),
    );

    expect(heightField.controller?.text, '180.0');
  });

  testWidgets(
      'pré-remplit également la taille depuis le profil à l\'édition d\'une mesure existante',
      (tester) async {
    final existingMeasurement = BodyMeasurement(
      id: 'measurement-1',
      recordedAt: DateTime(2026, 3, 5),
      weight: 80.0,
    );

    await pumpForm(
      tester,
      measurementToEdit: existingMeasurement,
      profileHeight: 180.0,
    );

    final heightField = tester.widget<TextFormField>(
      find.ancestor(
        of: find.text('Taille (cm)'),
        matching: find.byType(TextFormField),
      ),
    );

    expect(heightField.controller?.text, '180.0');
  });
}
