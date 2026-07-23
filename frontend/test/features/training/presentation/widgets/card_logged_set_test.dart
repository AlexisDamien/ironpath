import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/models/training_session.dart';
import 'package:ironpath/features/training/presentation/widgets/card_logged_set.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('displays the exercise name', (tester) async {
    final set = ExerciseSet(
      id: 'set-1',
      exerciseId: 'ex-1',
      setOrder: 1,
      reps: 10,
      weightKg: 50.0,
      restSeconds: 90,
      isWarmup: false,
    );

    await tester.pumpWidget(
      wrap(CardLoggedSet(exerciseSet: set, exerciseName: 'Squat')),
    );

    expect(find.text('Squat'), findsOneWidget);
  });

  testWidgets('displays the set order in the leading avatar', (
    tester,
  ) async {
    final set = ExerciseSet(
      id: 'set-1',
      exerciseId: 'ex-1',
      setOrder: 3,
      isWarmup: false,
    );

    await tester.pumpWidget(
      wrap(CardLoggedSet(exerciseSet: set, exerciseName: 'Squat')),
    );

    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('displays reps, weight and rest when all provided', (
    tester,
  ) async {
    final set = ExerciseSet(
      id: 'set-1',
      exerciseId: 'ex-1',
      setOrder: 1,
      reps: 10,
      weightKg: 50.0,
      restSeconds: 90,
      isWarmup: false,
    );

    await tester.pumpWidget(
      wrap(CardLoggedSet(exerciseSet: set, exerciseName: 'Squat')),
    );

    expect(find.text('10 reps • 50.0 kg • 1min30s repos'), findsOneWidget);
  });

  testWidgets('falls back to placeholders when reps/weight are missing', (
    tester,
  ) async {
    final set = ExerciseSet(
      id: 'set-1',
      exerciseId: 'ex-1',
      setOrder: 1,
      isWarmup: false,
    );

    await tester.pumpWidget(
      wrap(CardLoggedSet(exerciseSet: set, exerciseName: 'Squat')),
    );

    expect(find.text('- reps • - kg • - repos'), findsOneWidget);
  });
}
