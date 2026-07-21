import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/models/training_session.dart';
import 'package:ironpath/features/training/presentation/widgets/sheet_add_set.dart';

void main() {
  final activeSession = TrainingSession(
    id: 'session-1',
    status: 'IN_PROGRESS',
    sets: const [],
    plannedExercises: const [],
    startedAt: DateTime(2026, 3, 5, 10, 0),
  );

  Widget wrap(Widget child) {
    return ProviderScope(child: MaterialApp(home: Scaffold(body: child)));
  }

  testWidgets('displays the initial empty form state', (tester) async {
    await tester.pumpWidget(
      wrap(SheetAddSet(activeSession: activeSession)),
    );

    expect(find.text('Ajouter une série'), findsOneWidget);
    expect(find.text('Choisir un exercice'), findsOneWidget);
    expect(find.text('Répétitions'), findsOneWidget);
    expect(find.text('Poids (kg)'), findsOneWidget);
    expect(find.text('Temps de repos (secondes)'), findsOneWidget);
    expect(find.text('Ajouter la série'), findsOneWidget);
  });

  testWidgets(
    'shows an error when submitting without selecting an exercise',
    (tester) async {
      await tester.pumpWidget(
        wrap(SheetAddSet(activeSession: activeSession)),
      );

      expect(find.text('Sélectionnez un exercice.'), findsNothing);

      await tester.tap(find.text('Ajouter la série'));
      await tester.pumpAndSettle();

      expect(find.text('Sélectionnez un exercice.'), findsOneWidget);
    },
  );

  testWidgets('shows a validation error for a negative reps value', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(SheetAddSet(activeSession: activeSession)),
    );

    await tester.enterText(
      find.ancestor(
        of: find.text('Répétitions'),
        matching: find.byType(TextFormField),
      ),
      '-5',
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Le nombre de répétitions doit être un nombre entier positif'),
      findsOneWidget,
    );
  });

  testWidgets('shows a validation error for a negative weight value', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(SheetAddSet(activeSession: activeSession)),
    );

    await tester.enterText(
      find.ancestor(
        of: find.text('Poids (kg)'),
        matching: find.byType(TextFormField),
      ),
      '-10',
    );
    await tester.pumpAndSettle();

    expect(find.text('Le poids doit être un nombre positif'), findsOneWidget);
  });

  testWidgets('accepts an empty reps field without showing an error', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(SheetAddSet(activeSession: activeSession)),
    );

    await tester.enterText(
      find.ancestor(
        of: find.text('Répétitions'),
        matching: find.byType(TextFormField),
      ),
      '',
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Le nombre de répétitions doit être un nombre entier positif'),
      findsNothing,
    );
  });

  testWidgets('toggles the warmup switch', (tester) async {
    await tester.pumpWidget(
      wrap(SheetAddSet(activeSession: activeSession)),
    );

    final switchTileBefore = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(switchTileBefore.value, isFalse);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    final switchTileAfter = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(switchTileAfter.value, isTrue);
  });
}
