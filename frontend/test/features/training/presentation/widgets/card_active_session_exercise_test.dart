import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/models/set_target.dart';
import 'package:ironpath/features/training/domain/models/training_session.dart';
import 'package:ironpath/features/training/presentation/widgets/card_active_session_exercise.dart';

void main() {
  Widget wrap(Widget child) {
    return ProviderScope(child: MaterialApp(home: Scaffold(body: child)));
  }

  void noopLogSet({
    required int setOrder,
    required int? reps,
    required double? weightKg,
    required int? restSeconds,
    required bool isWarmup,
  }) {}

  testWidgets('displays exercise name and progress count', (tester) async {
    await tester.pumpWidget(
      wrap(
        CardActiveSessionExercise(
          exerciseKey: 'ex-1',
          exerciseName: 'Squat',
          muscleGroup: 'Jambes',
          plannedSets: [SetTarget(setOrder: 1), SetTarget(setOrder: 2)],
          loggedSets: const [],
          onLogSet: noopLogSet,
        ),
      ),
    );

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('0/2 séries • Jambes'), findsOneWidget);
  });

  testWidgets('shows editable reps/weight fields for a set not yet logged', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        CardActiveSessionExercise(
          exerciseKey: 'ex-1',
          exerciseName: 'Squat',
          plannedSets: [SetTarget(setOrder: 1)],
          loggedSets: const [],
          onLogSet: noopLogSet,
        ),
      ),
    );

    expect(find.text('Reps'), findsOneWidget);
    expect(find.text('Kg'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('displays reps and weight for a logged set', (tester) async {
    final loggedSet = ExerciseSet(
      id: 'set-1',
      exerciseId: 'ex-1',
      setOrder: 1,
      reps: 10,
      weightKg: 50.0,
      restSeconds: 90,
      isWarmup: false,
    );

    await tester.pumpWidget(
      wrap(
        CardActiveSessionExercise(
          exerciseKey: 'ex-1',
          exerciseName: 'Squat',
          plannedSets: [SetTarget(setOrder: 1, targetReps: 10, targetWeight: 50)],
          loggedSets: [loggedSet],
          onLogSet: noopLogSet,
        ),
      ),
    );

    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();

    expect(find.text('10 reps • 50.0 kg'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('calls onLogSet with the parsed values when validated', (
    tester,
  ) async {
    Map<String, Object?>? captured;

    await tester.pumpWidget(
      wrap(
        CardActiveSessionExercise(
          exerciseKey: 'ex-1',
          exerciseName: 'Squat',
          plannedSets: [SetTarget(setOrder: 1, targetReps: 8, targetWeight: 40)],
          loggedSets: const [],
          onLogSet: ({
            required setOrder,
            required reps,
            required weightKg,
            required restSeconds,
            required isWarmup,
          }) {
            captured = {
              'setOrder': setOrder,
              'reps': reps,
              'weightKg': weightKg,
              'restSeconds': restSeconds,
              'isWarmup': isWarmup,
            };
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.check_circle_outline));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!['setOrder'], 1);
    expect(captured!['reps'], 8);
    expect(captured!['weightKg'], 40.0);
    expect(captured!['restSeconds'], isNull);
    expect(captured!['isWarmup'], isFalse);
  });

  testWidgets('shows the warmup icon for a planned warmup set', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        CardActiveSessionExercise(
          exerciseKey: 'ex-1',
          exerciseName: 'Squat',
          plannedSets: [SetTarget(setOrder: 1, isWarmup: true)],
          loggedSets: const [],
          onLogSet: noopLogSet,
        ),
      ),
    );

    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
  });

  testWidgets(
    'shows the planned rest timer when restSeconds is set and not logged',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          CardActiveSessionExercise(
            exerciseKey: 'ex-1',
            exerciseName: 'Squat',
            plannedSets: [SetTarget(setOrder: 1, restSeconds: 90)],
            loggedSets: const [],
            onLogSet: noopLogSet,
          ),
        ),
      );

      expect(find.text('01:30'), findsOneWidget);
    },
  );

  testWidgets('shows the formatted rest duration for a logged set', (
    tester,
  ) async {
    final loggedSet = ExerciseSet(
      id: 'set-1',
      exerciseId: 'ex-1',
      setOrder: 1,
      reps: 10,
      weightKg: 50.0,
      restSeconds: 95,
      isWarmup: false,
    );

    await tester.pumpWidget(
      wrap(
        CardActiveSessionExercise(
          exerciseKey: 'ex-1',
          exerciseName: 'Squat',
          plannedSets: [SetTarget(setOrder: 1)],
          loggedSets: [loggedSet],
          onLogSet: noopLogSet,
        ),
      ),
    );

    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();

    expect(find.text('1min35s repos'), findsOneWidget);
  });

  testWidgets('tapping the check icon on a done set switches back to edit', (
    tester,
  ) async {
    final loggedSet = ExerciseSet(
      id: 'set-1',
      exerciseId: 'ex-1',
      setOrder: 1,
      reps: 10,
      weightKg: 50.0,
      restSeconds: 90,
      isWarmup: false,
    );

    await tester.pumpWidget(
      wrap(
        CardActiveSessionExercise(
          exerciseKey: 'ex-1',
          exerciseName: 'Squat',
          plannedSets: [SetTarget(setOrder: 1)],
          loggedSets: [loggedSet],
          onLogSet: noopLogSet,
        ),
      ),
    );

    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.tap(find.byIcon(Icons.check_circle));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });
}
