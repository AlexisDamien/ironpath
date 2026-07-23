import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/models/exercise.dart';
import 'package:ironpath/features/training/domain/models/exercise_config.dart';
import 'package:ironpath/features/training/domain/models/exercise_set_config.dart';
import 'package:ironpath/features/training/presentation/widgets/card_selected_exercise.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  final exercise = Exercise(
    id: 'ex-1',
    name: 'Développé couché',
    muscleGroup: 'Pectoraux',
  );

  testWidgets('displays the exercise name', (tester) async {
    final config = ExerciseConfig(
      exercise: exercise,
      sets: [ExerciseSetConfig(setOrder: 1)],
    );

    await tester.pumpWidget(
      wrap(
        CardSelectedExercise(
          index: 0,
          config: config,
          onEdit: () {},
          onRemove: () {},
        ),
      ),
    );

    expect(find.text('Développé couché'), findsOneWidget);
  });

  testWidgets('displays singular set count and muscle group', (tester) async {
    final config = ExerciseConfig(
      exercise: exercise,
      sets: [ExerciseSetConfig(setOrder: 1)],
    );

    await tester.pumpWidget(
      wrap(
        CardSelectedExercise(
          index: 0,
          config: config,
          onEdit: () {},
          onRemove: () {},
        ),
      ),
    );

    expect(find.text('1 série • Pectoraux'), findsOneWidget);
  });

  testWidgets('displays plural set count when more than one set', (
    tester,
  ) async {
    final config = ExerciseConfig(
      exercise: exercise,
      sets: [
        ExerciseSetConfig(setOrder: 1),
        ExerciseSetConfig(setOrder: 2),
        ExerciseSetConfig(setOrder: 3),
      ],
    );

    await tester.pumpWidget(
      wrap(
        CardSelectedExercise(
          index: 0,
          config: config,
          onEdit: () {},
          onRemove: () {},
        ),
      ),
    );

    expect(find.text('3 séries • Pectoraux'), findsOneWidget);
  });

  testWidgets('calls onEdit when "Modifier" is selected from the menu', (
    tester,
  ) async {
    var editTapped = false;
    final config = ExerciseConfig(
      exercise: exercise,
      sets: [ExerciseSetConfig(setOrder: 1)],
    );

    await tester.pumpWidget(
      wrap(
        CardSelectedExercise(
          index: 0,
          config: config,
          onEdit: () => editTapped = true,
          onRemove: () {},
        ),
      ),
    );

    await tester.tap(find.byTooltip('Actions pour Développé couché'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();

    expect(editTapped, isTrue);
  });

  testWidgets('calls onRemove when "Supprimer" is selected from the menu', (
    tester,
  ) async {
    var removeTapped = false;
    final config = ExerciseConfig(
      exercise: exercise,
      sets: [ExerciseSetConfig(setOrder: 1)],
    );

    await tester.pumpWidget(
      wrap(
        CardSelectedExercise(
          index: 0,
          config: config,
          onEdit: () {},
          onRemove: () => removeTapped = true,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Actions pour Développé couché'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    expect(removeTapped, isTrue);
  });

  testWidgets('expands to show set details when tapped', (tester) async {
    final config = ExerciseConfig(
      exercise: exercise,
      sets: [ExerciseSetConfig(setOrder: 1, targetReps: 10, targetWeight: 50)],
    );

    await tester.pumpWidget(
      wrap(
        CardSelectedExercise(
          index: 0,
          config: config,
          onEdit: () {},
          onRemove: () {},
        ),
      ),
    );

    await tester.tap(find.text('Développé couché'));
    await tester.pumpAndSettle();

    expect(find.text('Série 1'), findsOneWidget);
    expect(find.text('10 reps • 50.0 kg'), findsOneWidget);
  });

  testWidgets('shows a warmup icon for sets marked as warmup', (
    tester,
  ) async {
    final config = ExerciseConfig(
      exercise: exercise,
      sets: [
        ExerciseSetConfig(setOrder: 1, targetReps: 10, isWarmup: true),
        ExerciseSetConfig(setOrder: 2, targetReps: 8, isWarmup: false),
      ],
    );

    await tester.pumpWidget(
      wrap(
        CardSelectedExercise(
          index: 0,
          config: config,
          onEdit: () {},
          onRemove: () {},
        ),
      ),
    );

    await tester.tap(find.text('Développé couché'));
    await tester.pumpAndSettle();

    // Une icône résumée dans le titre (visible replié, pendant le
    // réordonnancement), et une seconde au niveau du détail de la série
    // concernée une fois la carte dépliée.
    expect(find.byIcon(Icons.local_fire_department), findsNWidgets(2));
  });

  testWidgets('shows the warmup icon on the collapsed card, without expanding',
      (tester) async {
    final config = ExerciseConfig(
      exercise: exercise,
      sets: [ExerciseSetConfig(setOrder: 1, isWarmup: true)],
    );

    await tester.pumpWidget(
      wrap(
        CardSelectedExercise(
          index: 0,
          config: config,
          onEdit: () {},
          onRemove: () {},
        ),
      ),
    );

    // Aucun tap pour déplier la carte : l'icône doit être visible telle
    // quelle, notamment pendant le réordonnancement par glisser-déposer.
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
  });

  testWidgets(
      'does not show a warmup icon on the collapsed card when no set is a warmup',
      (tester) async {
    final config = ExerciseConfig(
      exercise: exercise,
      sets: [ExerciseSetConfig(setOrder: 1, isWarmup: false)],
    );

    await tester.pumpWidget(
      wrap(
        CardSelectedExercise(
          index: 0,
          config: config,
          onEdit: () {},
          onRemove: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.local_fire_department), findsNothing);
  });
}
