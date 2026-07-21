import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/models/exercise.dart';
import 'package:ironpath/features/training/domain/models/exercise_config.dart';
import 'package:ironpath/features/training/domain/models/exercise_set_config.dart';
import 'package:ironpath/features/training/presentation/widgets/popup_exercise_config.dart';

void main() {
  final exercise = Exercise(
    id: 'ex-1',
    name: 'Développé couché',
    muscleGroup: 'Pectoraux',
    equipment: 'Barre',
  );

  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  TextField findFieldByLabel(WidgetTester tester, String label) {
    return tester.widget<TextField>(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(TextField),
      ),
    );
  }

  testWidgets('displays the exercise name and muscle group / equipment', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(PopupExerciseConfig(exercise: exercise)),
    );

    expect(find.text('Développé couché'), findsOneWidget);
    expect(find.text('Pectoraux • Barre'), findsOneWidget);
  });

  testWidgets('defaults to 3 sets with default reps/rest values', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(PopupExerciseConfig(exercise: exercise)),
    );

    final setsCountField = findFieldByLabel(tester, 'Nombre de séries');
    expect(setsCountField.controller?.text, '3');

    final repsField = findFieldByLabel(tester, 'Répétitions');
    expect(repsField.controller?.text, '10');

    final restField = findFieldByLabel(tester, 'Repos (s)');
    expect(restField.controller?.text, '90');
  });

  testWidgets('pre-fills fields from an existing config', (tester) async {
    final existingConfig = ExerciseConfig(
      exercise: exercise,
      sets: [
        ExerciseSetConfig(setOrder: 1, targetReps: 8, targetWeight: 60),
      ],
    );

    await tester.pumpWidget(
      wrap(
        PopupExerciseConfig(exercise: exercise, existingConfig: existingConfig),
      ),
    );

    final repsField = findFieldByLabel(tester, 'Répétitions');
    expect(repsField.controller?.text, '8');

    expect(find.text('Enregistrer les modifications'), findsOneWidget);
    expect(find.text('Ajouter l’exercice'), findsNothing);
  });

  testWidgets('shows per-set fields when "same config" is turned off', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(PopupExerciseConfig(exercise: exercise)),
    );

    expect(find.text('Répétitions'), findsOneWidget);

    await tester.tap(find.text('Même config pour toutes les séries'));
    await tester.pumpAndSettle();

    expect(find.text('Répétitions'), findsNothing);
    expect(find.text('Série 1'), findsOneWidget);
    expect(find.text('Série 2'), findsOneWidget);
    expect(find.text('Série 3'), findsOneWidget);
  });

  testWidgets('rebuilds per-set fields when the sets count changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(PopupExerciseConfig(exercise: exercise)),
    );

    await tester.tap(find.text('Même config pour toutes les séries'));
    await tester.pumpAndSettle();
    expect(find.text('Série 3'), findsOneWidget);
    expect(find.text('Série 5'), findsNothing);

    await tester.enterText(
      find.ancestor(
        of: find.text('Nombre de séries'),
        matching: find.byType(TextField),
      ),
      '5',
    );
    await tester.pumpAndSettle();

    expect(find.text('Série 5'), findsOneWidget);
  });

  testWidgets('submit button label reflects creation vs edition mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(PopupExerciseConfig(exercise: exercise)),
    );

    expect(find.text('Ajouter l’exercice'), findsOneWidget);
  });

  testWidgets('submitting pops the dialog with the built ExerciseConfig', (
    tester,
  ) async {
    ExerciseConfig? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<ExerciseConfig>(
                  context: context,
                  builder: (_) => PopupExerciseConfig(exercise: exercise),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajouter l’exercice'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.sets.length, 3);
    expect(result!.sets.first.targetReps, 10);
    expect(result!.sets.first.restSeconds, 90);
  });
}
