import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ironpath/features/bodymetrics/domain/state_bodymetrics.dart';
import 'package:ironpath/features/bodymetrics/presentation/providers/provider_bodymetrics.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockRepositoryBodyMetrics repository;
  late ProviderBodyMetricsNotifier notifier;

  setUp(() {
    repository = MockRepositoryBodyMetrics();
    notifier = ProviderBodyMetricsNotifier(repository);
  });

  tearDown(() => notifier.dispose());

  test('loadMeasurements initialise la liste', () async {
    final measurement = measurementFixture();
    when(() => repository.getMeasurements())
        .thenAnswer((_) async => [measurement]);

    await notifier.loadMeasurements();

    expect(notifier.state.status, StatusBodyMetrics.success);
    expect(notifier.state.measurements, [measurement]);
    expect(notifier.state.isInitialized, isTrue);
  });

  test('loadMeasurements expose les erreurs', () async {
    when(() => repository.getMeasurements()).thenThrow(Exception('offline'));

    await notifier.loadMeasurements();

    expect(notifier.state.status, StatusBodyMetrics.error);
    expect(notifier.state.errorMessage, 'offline');
  });

  test('saveMeasurement sauvegarde puis recharge', () async {
    when(
      () => repository.saveMeasurement(
        weight: 82,
        chest: null,
        waist: null,
        hips: null,
        leftArm: null,
        rightArm: null,
        leftThigh: null,
        rightThigh: null,
        leftCalf: null,
        rightCalf: null,
        notes: 'Matin',
        recordedAt: null,
      ),
    ).thenAnswer((_) async => measurementFixture());
    when(() => repository.getMeasurements())
        .thenAnswer((_) async => [measurementFixture()]);

    await notifier.saveMeasurement(weight: 82, notes: 'Matin');

    verify(
      () => repository.saveMeasurement(
        weight: 82,
        chest: null,
        waist: null,
        hips: null,
        leftArm: null,
        rightArm: null,
        leftThigh: null,
        rightThigh: null,
        leftCalf: null,
        rightCalf: null,
        notes: 'Matin',
        recordedAt: null,
      ),
    ).called(1);
    verify(() => repository.getMeasurements()).called(1);
  });

  test('deleteMeasurement supprime puis recharge', () async {
    when(() => repository.deleteMeasurement('m1')).thenAnswer((_) async {});
    when(() => repository.getMeasurements()).thenAnswer((_) async => []);

    await notifier.deleteMeasurement('m1');

    verify(() => repository.deleteMeasurement('m1')).called(1);
    expect(notifier.state.measurements, isEmpty);
  });

  test('loadCompositions initialise la liste', () async {
    final composition = compositionFixture();
    when(() => repository.getCompositions())
        .thenAnswer((_) async => [composition]);

    await notifier.loadCompositions();

    expect(notifier.state.compositions, [composition]);
    expect(notifier.state.isInitialized, isTrue);
  });

  test('saveComposition sauvegarde puis recharge', () async {
    when(
      () => repository.saveComposition(
        bodyFat: 15.2,
        skeletalMuscle: null,
        fatFreeMass: null,
        subcutaneousFat: null,
        visceralFat: null,
        bodyWater: null,
        muscleMass: null,
        boneMass: null,
        protein: null,
        bmr: null,
        notes: null,
        recordedAt: null,
      ),
    ).thenAnswer((_) async => compositionFixture());
    when(() => repository.getCompositions())
        .thenAnswer((_) async => [compositionFixture()]);

    await notifier.saveComposition(bodyFat: 15.2);

    verify(() => repository.getCompositions()).called(1);
  });

  test('updateMeasurement met à jour puis recharge', () async {
    when(
      () => repository.updateMeasurement(
        measurementId: 'm1',
        weight: 83,
        chest: null,
        waist: null,
        hips: null,
        leftArm: null,
        rightArm: null,
        leftThigh: null,
        rightThigh: null,
        leftCalf: null,
        rightCalf: null,
        notes: null,
      ),
    ).thenAnswer((_) async => measurementFixture(id: 'm1'));
    when(() => repository.getMeasurements())
        .thenAnswer((_) async => [measurementFixture(id: 'm1')]);

    await notifier.updateMeasurement(measurementId: 'm1', weight: 83);

    verify(() => repository.getMeasurements()).called(1);
    expect(notifier.state.measurements.single.id, 'm1');
  });

  test('updateComposition met à jour puis recharge', () async {
    when(
      () => repository.updateComposition(
        compositionId: 'c1',
        bodyFat: 14.5,
        skeletalMuscle: null,
        fatFreeMass: null,
        subcutaneousFat: null,
        visceralFat: null,
        bodyWater: null,
        muscleMass: null,
        boneMass: null,
        protein: null,
        bmr: null,
        notes: null,
      ),
    ).thenAnswer((_) async => compositionFixture(id: 'c1'));
    when(() => repository.getCompositions())
        .thenAnswer((_) async => [compositionFixture(id: 'c1')]);

    await notifier.updateComposition(compositionId: 'c1', bodyFat: 14.5);

    verify(() => repository.getCompositions()).called(1);
    expect(notifier.state.compositions.single.id, 'c1');
  });

  test('deleteComposition supprime puis recharge', () async {
    when(() => repository.deleteComposition('c1')).thenAnswer((_) async {});
    when(() => repository.getCompositions()).thenAnswer((_) async => []);

    await notifier.deleteComposition('c1');

    verify(() => repository.deleteComposition('c1')).called(1);
    expect(notifier.state.compositions, isEmpty);
  });

  test('une erreur de mutation place le provider en erreur', () async {
    when(() => repository.deleteComposition('c1'))
        .thenThrow(Exception('suppression refusée'));

    await notifier.deleteComposition('c1');

    expect(notifier.state.status, StatusBodyMetrics.error);
    expect(notifier.state.errorMessage, 'suppression refusée');
  });
}
