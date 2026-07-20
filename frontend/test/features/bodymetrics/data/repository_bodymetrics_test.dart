import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ironpath/features/bodymetrics/data/repository_bodymetrics.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

Response<dynamic> response(Object? data) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/test'),
      statusCode: 200,
      data: data,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  late MockApiClient apiClient;
  late RepositoryBodyMetrics repository;

  setUp(() {
    apiClient = MockApiClient();
    repository = RepositoryBodyMetrics(apiClient);
  });

  test('getMeasurements convertit la liste', () async {
    when(() => apiClient.get('/api/bodymetrics/measurements'))
        .thenAnswer((_) async => response([measurementJson()]));

    final measurements = await repository.getMeasurements();

    expect(measurements, hasLength(1));
    expect(measurements.single.weight, 82.0);
  });

  test('saveMeasurement sérialise toutes les valeurs', () async {
    final date = DateTime.parse('2026-07-20T08:30:00.000Z');
    final data = {
      'weight': 82.0,
      'chest': 101.0,
      'waist': null,
      'hips': null,
      'leftArm': null,
      'rightArm': null,
      'leftThigh': null,
      'rightThigh': null,
      'leftCalf': null,
      'rightCalf': null,
      'notes': 'Matin',
      'recordedAt': date.toIso8601String(),
    };
    when(
      () => apiClient.post(
        '/api/bodymetrics/measurements',
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => response(measurementJson()));

    final result = await repository.saveMeasurement(
      weight: 82,
      chest: 101,
      notes: 'Matin',
      recordedAt: date,
    );

    expect(result.id, 'measurement-1');
    final captured = verify(
      () => apiClient.post(
        '/api/bodymetrics/measurements',
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(captured, data);
  });

  test('updateMeasurement utilise l’identifiant dans la route', () async {
    final data = {
      'weight': 83.0,
      'chest': null,
      'waist': null,
      'hips': null,
      'leftArm': null,
      'rightArm': null,
      'leftThigh': null,
      'rightThigh': null,
      'leftCalf': null,
      'rightCalf': null,
      'notes': null,
    };
    when(
      () => apiClient.put(
        '/api/bodymetrics/measurements/m1',
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => response(measurementJson(id: 'm1')));

    final result = await repository.updateMeasurement(
      measurementId: 'm1',
      weight: 83,
    );

    expect(result.id, 'm1');
    final captured = verify(
      () => apiClient.put(
        '/api/bodymetrics/measurements/m1',
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(captured, data);
  });

  test('deleteMeasurement utilise la bonne route', () async {
    when(() => apiClient.delete('/api/bodymetrics/measurements/m1'))
        .thenAnswer((_) async => response(null));

    await repository.deleteMeasurement('m1');

    verify(() => apiClient.delete('/api/bodymetrics/measurements/m1'))
        .called(1);
  });

  test('getCompositions convertit la liste', () async {
    when(() => apiClient.get('/api/bodymetrics/compositions'))
        .thenAnswer((_) async => response([compositionJson()]));

    final compositions = await repository.getCompositions();

    expect(compositions, hasLength(1));
    expect(compositions.single.bodyFat, 15.2);
  });

  test('saveComposition sérialise les valeurs', () async {
    final data = {
      'bodyFat': 15.2,
      'skeletalMuscle': null,
      'fatFreeMass': null,
      'subcutaneousFat': null,
      'visceralFat': 7,
      'bodyWater': null,
      'muscleMass': null,
      'boneMass': null,
      'protein': null,
      'bmr': 1820,
      'notes': 'Balance',
      'recordedAt': null,
    };
    when(
      () => apiClient.post(
        '/api/bodymetrics/compositions',
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => response(compositionJson()));

    final result = await repository.saveComposition(
      bodyFat: 15.2,
      visceralFat: 7,
      bmr: 1820,
      notes: 'Balance',
    );

    expect(result.id, 'composition-1');
    final captured = verify(
      () => apiClient.post(
        '/api/bodymetrics/compositions',
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(captured, data);
  });

  test('updateComposition et deleteComposition utilisent les bonnes routes',
      () async {
    final data = {
      'bodyFat': 14.5,
      'skeletalMuscle': null,
      'fatFreeMass': null,
      'subcutaneousFat': null,
      'visceralFat': null,
      'bodyWater': null,
      'muscleMass': null,
      'boneMass': null,
      'protein': null,
      'bmr': null,
      'notes': null,
    };
    when(
      () => apiClient.put(
        '/api/bodymetrics/compositions/c1',
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => response(compositionJson(id: 'c1')));
    when(() => apiClient.delete('/api/bodymetrics/compositions/c1'))
        .thenAnswer((_) async => response(null));

    final result = await repository.updateComposition(
      compositionId: 'c1',
      bodyFat: 14.5,
    );
    await repository.deleteComposition('c1');

    expect(result.id, 'c1');
    final captured = verify(
      () => apiClient.put(
        '/api/bodymetrics/compositions/c1',
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(captured, data);
    verify(() => apiClient.delete('/api/bodymetrics/compositions/c1'))
        .called(1);
  });
}
