import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ironpath/features/training/data/repository_training.dart';
import 'package:ironpath/features/training/domain/models/exercise_config.dart';
import 'package:ironpath/features/training/domain/models/exercise_set_config.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

Response<dynamic> response(Object? data, {int statusCode = 200}) =>
    Response<dynamic>(
      requestOptions: RequestOptions(path: '/test'),
      statusCode: statusCode,
      data: data,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  late MockApiClient apiClient;
  late RepositoryTraining repository;

  setUp(() {
    apiClient = MockApiClient();
    repository = RepositoryTraining(apiClient);
  });

  test('getPrograms convertit la liste', () async {
    when(() => apiClient.get('/api/training/programs'))
        .thenAnswer((_) async => response([programJson()]));

    final programs = await repository.getPrograms();

    expect(programs, hasLength(1));
    expect(programs.single.name, 'Push');
  });

  test('createProgram sérialise les exercices dans leur ordre', () async {
    final exercises = [
      ExerciseConfig(
        exercise: exerciseFixture(id: 'e1'),
        sameConfigForAllSets: false,
        sets: [
          ExerciseSetConfig(
            setOrder: 1,
            targetReps: 12,
            targetWeight: 40,
            restSeconds: 60,
            isWarmup: true,
          ),
        ],
      ),
      ExerciseConfig(
        exercise: exerciseFixture(id: 'e2', name: 'Développé militaire'),
        sets: [ExerciseSetConfig(setOrder: 1, targetReps: 8)],
      ),
    ];
    final expectedData = {
      'name': 'Push',
      'description': 'Poussée',
      'exercises': [
        {
          'exerciseId': 'e1',
          'exerciseOrder': 1,
          'sameConfigForAllSets': false,
          'sets': [
            {
              'setOrder': 1,
              'targetReps': 12,
              'targetWeightKg': 40.0,
              'restSeconds': 60,
              'isWarmup': true,
            },
          ],
        },
        {
          'exerciseId': 'e2',
          'exerciseOrder': 2,
          'sameConfigForAllSets': true,
          'sets': [
            {
              'setOrder': 1,
              'targetReps': 8,
              'targetWeightKg': null,
              'restSeconds': null,
              'isWarmup': false,
            },
          ],
        },
      ],
    };
    when(
      () => apiClient.post(
        '/api/training/programs',
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => response(programJson()));

    final program = await repository.createProgram(
      name: 'Push',
      description: 'Poussée',
      exercises: exercises,
    );

    expect(program.id, 'program-1');
    final captured = verify(
      () => apiClient.post(
        '/api/training/programs',
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(captured, expectedData);
  });

  test('updateProgram utilise l’identifiant dans la route', () async {
    final expectedData = {
      'name': 'Push 2',
      'description': null,
      'exercises': <Map<String, dynamic>>[],
    };
    when(
      () => apiClient.put(
        '/api/training/programs/p1',
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => response(programJson(id: 'p1')));

    final program = await repository.updateProgram(
      programId: 'p1',
      name: 'Push 2',
    );

    expect(program.id, 'p1');
    final captured = verify(
      () => apiClient.put(
        '/api/training/programs/p1',
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(captured, expectedData);
  });

  test('deleteProgram utilise la bonne route', () async {
    when(() => apiClient.delete('/api/training/programs/p1'))
        .thenAnswer((_) async => response(null));

    await repository.deleteProgram('p1');

    verify(() => apiClient.delete('/api/training/programs/p1')).called(1);
  });

  test('startSession transmet le programme et le nom', () async {
    when(
      () => apiClient.post(
        '/api/training/sessions',
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => response(sessionJson()));

    final session = await repository.startSession(
      programId: 'p1',
      name: 'Push du lundi',
    );

    expect(session.id, 'session-1');
    final captured = verify(
      () => apiClient.post(
        '/api/training/sessions',
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(captured, {'programId': 'p1', 'name': 'Push du lundi'});
  });

  test('getActiveSession retourne null pour une réponse 204', () async {
    when(() => apiClient.get('/api/training/sessions/active'))
        .thenAnswer((_) async => response(null, statusCode: 204));

    expect(await repository.getActiveSession(), isNull);
  });

  test('getActiveSession retourne null si le repository rencontre une erreur',
      () async {
    when(() => apiClient.get('/api/training/sessions/active'))
        .thenThrow(Exception('offline'));

    expect(await repository.getActiveSession(), isNull);
  });

  test('addSet sérialise une série', () async {
    final data = {
      'exerciseId': 'e1',
      'setOrder': 2,
      'reps': 8,
      'weightKg': 85.0,
      'restSeconds': 100,
      'isWarmup': false,
    };
    when(
      () => apiClient.post(
        '/api/training/sessions/s1/sets',
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => response(sessionJson(id: 's1')));

    final session = await repository.addSet(
      sessionId: 's1',
      exerciseId: 'e1',
      setOrder: 2,
      reps: 8,
      weightKg: 85,
      restSeconds: 100,
    );

    expect(session.id, 's1');
    final captured = verify(
      () => apiClient.post(
        '/api/training/sessions/s1/sets',
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(captured, data);
  });

  test('endSession utilise PUT sur la route de fin', () async {
    when(() => apiClient.put('/api/training/sessions/s1/end'))
        .thenAnswer((_) async => response(sessionJson(id: 's1')));

    await repository.endSession('s1');

    verify(() => apiClient.put('/api/training/sessions/s1/end')).called(1);
  });

  test('getSessionHistory convertit la liste', () async {
    when(() => apiClient.get('/api/training/sessions'))
        .thenAnswer((_) async => response([sessionJson()]));

    expect(await repository.getSessionHistory(), hasLength(1));
  });

  test('getExercises transmet uniquement les filtres présents', () async {
    when(
      () => apiClient.get(
        '/api/exercises',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => response([exerciseJson()]));

    final exercises = await repository.getExercises(
      search: 'développé',
      muscleGroup: 'CHEST',
    );

    expect(exercises.single.name, 'Développé couché');
    final captured = verify(
      () => apiClient.get(
        '/api/exercises',
        queryParameters: captureAny(named: 'queryParameters'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(captured, {
      'search': 'développé',
      'muscleGroup': 'CHEST',
    });
  });
}
