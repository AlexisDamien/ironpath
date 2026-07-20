import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ironpath/features/training/domain/models/exercise_config.dart';
import 'package:ironpath/features/training/domain/models/exercise_set_config.dart';
import 'package:ironpath/features/training/domain/state_training.dart';
import 'package:ironpath/features/training/presentation/providers/provider_training.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockRepositoryTraining repository;
  late ProviderTrainingNotifier notifier;

  setUp(() {
    repository = MockRepositoryTraining();
    notifier = ProviderTrainingNotifier(repository);
  });

  tearDown(() => notifier.dispose());

  test('loadPrograms charge les programmes', () async {
    final program = programFixture();
    when(() => repository.getPrograms()).thenAnswer((_) async => [program]);

    await notifier.loadPrograms();

    expect(notifier.state.status, StatusTraining.success);
    expect(notifier.state.programs, [program]);
  });

  test('loadPrograms expose une erreur', () async {
    when(() => repository.getPrograms()).thenThrow(Exception('offline'));

    await notifier.loadPrograms();

    expect(notifier.state.status, StatusTraining.error);
    expect(notifier.state.errorMessage, 'offline');
  });

  test('loadActiveSession remplace la séance active', () async {
    final session = sessionFixture();
    when(() => repository.getActiveSession()).thenAnswer((_) async => session);

    await notifier.loadActiveSession();

    expect(notifier.state.activeSession, same(session));
  });

  test('loadActiveSession efface une ancienne séance lorsque null est retourné',
      () async {
    when(() => repository.startSession(programId: 'p1', name: null))
        .thenAnswer((_) async => sessionFixture());
    await notifier.startSession(programId: 'p1');

    when(() => repository.getActiveSession()).thenAnswer((_) async => null);
    await notifier.loadActiveSession();

    expect(notifier.state.activeSession, isNull);
  });

  test('createProgram crée puis recharge la liste', () async {
    final config = ExerciseConfig(
      exercise: exerciseFixture(),
      sets: [ExerciseSetConfig(setOrder: 1)],
    );
    final configs = [config];
    when(
      () => repository.createProgram(
        name: 'Push',
        description: null,
        exercises: configs,
      ),
    ).thenAnswer((_) async => programFixture());
    when(() => repository.getPrograms())
        .thenAnswer((_) async => [programFixture()]);

    await notifier.createProgram(name: 'Push', exercises: configs);

    verify(() => repository.getPrograms()).called(1);
    expect(notifier.state.status, StatusTraining.success);
  });

  test('deleteProgram supprime puis recharge les programmes', () async {
    when(() => repository.deleteProgram('p1')).thenAnswer((_) async {});
    when(() => repository.getPrograms()).thenAnswer((_) async => []);

    await notifier.deleteProgram('p1');

    verify(() => repository.deleteProgram('p1')).called(1);
    verify(() => repository.getPrograms()).called(1);
    expect(notifier.state.programs, isEmpty);
  });

  test('startSession renseigne activeSession', () async {
    final session = sessionFixture();
    when(() => repository.startSession(programId: 'p1', name: 'Push'))
        .thenAnswer((_) async => session);

    await notifier.startSession(programId: 'p1', name: 'Push');

    expect(notifier.state.status, StatusTraining.success);
    expect(notifier.state.activeSession, same(session));
  });

  test('addSet remplace la séance par la version serveur', () async {
    final updated = sessionFixture(id: 'updated');
    when(
      () => repository.addSet(
        sessionId: 's1',
        exerciseId: 'e1',
        setOrder: 1,
        reps: 10,
        weightKg: 80,
        restSeconds: 90,
        isWarmup: false,
      ),
    ).thenAnswer((_) async => updated);

    await notifier.addSet(
      sessionId: 's1',
      exerciseId: 'e1',
      setOrder: 1,
      reps: 10,
      weightKg: 80,
      restSeconds: 90,
    );

    expect(notifier.state.activeSession, same(updated));
  });

  test('endSession efface la séance et recharge les programmes', () async {
    when(() => repository.endSession('s1'))
        .thenAnswer((_) async => sessionFixture(status: 'COMPLETED'));
    when(() => repository.getPrograms()).thenAnswer((_) async => []);

    await notifier.endSession('s1');

    expect(notifier.state.activeSession, isNull);
    verify(() => repository.getPrograms()).called(1);
  });

  test('loadSessionHistory et loadExercises alimentent leurs listes', () async {
    final session = sessionFixture();
    final exercise = exerciseFixture();
    when(() => repository.getSessionHistory())
        .thenAnswer((_) async => [session]);
    when(
      () => repository.getExercises(search: 'dev', muscleGroup: 'CHEST'),
    ).thenAnswer((_) async => [exercise]);

    await notifier.loadSessionHistory();
    await notifier.loadExercises(search: 'dev', muscleGroup: 'CHEST');

    expect(notifier.state.sessionHistory, [session]);
    expect(notifier.state.exercises, [exercise]);
  });

  test('updateProgram met à jour puis recharge', () async {
    when(
      () => repository.updateProgram(
        programId: 'p1',
        name: 'Push 2',
        description: null,
        exercises: const [],
      ),
    ).thenAnswer((_) async => programFixture(id: 'p1'));
    when(() => repository.getPrograms())
        .thenAnswer((_) async => [programFixture(id: 'p1')]);

    await notifier.updateProgram(programId: 'p1', name: 'Push 2');

    verify(() => repository.getPrograms()).called(1);
    expect(notifier.state.status, StatusTraining.success);
  });
}
