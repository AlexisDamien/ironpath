import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/bodymetrics_repository.dart';
import '../../domain/bodymetrics_state.dart';

final bodyMetricsRepositoryProvider = Provider<BodyMetricsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BodyMetricsRepository(apiClient);
});

final bodyMetricsProvider =
    StateNotifierProvider<BodyMetricsNotifier, BodyMetricsState>((ref) {
  final repository = ref.watch(bodyMetricsRepositoryProvider);
  return BodyMetricsNotifier(repository);
});

class BodyMetricsNotifier extends StateNotifier<BodyMetricsState> {
  final BodyMetricsRepository _repository;

  BodyMetricsNotifier(this._repository) : super(const BodyMetricsState());

  Future<void> loadMeasurements() async {
    if (!state.isInitialized) {
      state = state.copyWith(status: BodyMetricsStatus.loading);
    }
    try {
      final measurements = await _repository.getMeasurements();
      state = state.copyWith(
        status: BodyMetricsStatus.success,
        measurements: measurements,
        isInitialized: true,
      );
    } catch (exception) {
      state = state.copyWith(
        status: BodyMetricsStatus.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> saveMeasurement({
    double? weight,
    double? chest,
    double? waist,
    double? hips,
    double? leftArm,
    double? rightArm,
    double? leftThigh,
    double? rightThigh,
    double? leftCalf,
    double? rightCalf,
    String? notes,
    DateTime? recordedAt,
  }) async {
    try {
      await _repository.saveMeasurement(
        weight: weight,
        chest: chest,
        waist: waist,
        hips: hips,
        leftArm: leftArm,
        rightArm: rightArm,
        leftThigh: leftThigh,
        rightThigh: rightThigh,
        leftCalf: leftCalf,
        rightCalf: rightCalf,
        notes: notes,
        recordedAt: recordedAt,
      );
      await loadMeasurements();
    } catch (exception) {
      state = state.copyWith(
        status: BodyMetricsStatus.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> loadCompositions() async {
    try {
      final compositions = await _repository.getCompositions();
      state = state.copyWith(
        status: BodyMetricsStatus.success,
        compositions: compositions,
        isInitialized: true,
      );
    } catch (exception) {
      state = state.copyWith(
        status: BodyMetricsStatus.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> saveComposition({
    double? bodyFat,
    double? skeletalMuscle,
    double? fatFreeMass,
    double? subcutaneousFat,
    int? visceralFat,
    double? bodyWater,
    double? muscleMass,
    double? boneMass,
    double? protein,
    int? bmr,
    String? notes,
    DateTime? recordedAt,
  }) async {
    try {
      await _repository.saveComposition(
        bodyFat: bodyFat,
        skeletalMuscle: skeletalMuscle,
        fatFreeMass: fatFreeMass,
        subcutaneousFat: subcutaneousFat,
        visceralFat: visceralFat,
        bodyWater: bodyWater,
        muscleMass: muscleMass,
        boneMass: boneMass,
        protein: protein,
        bmr: bmr,
        notes: notes,
        recordedAt: recordedAt,
      );
      await loadCompositions();
    } catch (exception) {
      state = state.copyWith(
        status: BodyMetricsStatus.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> updateMeasurement({
    required String measurementId,
    double? weight,
    double? chest,
    double? waist,
    double? hips,
    double? leftArm,
    double? rightArm,
    double? leftThigh,
    double? rightThigh,
    double? leftCalf,
    double? rightCalf,
    String? notes,
  }) async {
    try {
      await _repository.updateMeasurement(
        measurementId: measurementId,
        weight: weight,
        chest: chest,
        waist: waist,
        hips: hips,
        leftArm: leftArm,
        rightArm: rightArm,
        leftThigh: leftThigh,
        rightThigh: rightThigh,
        leftCalf: leftCalf,
        rightCalf: rightCalf,
        notes: notes,
      );
      await loadMeasurements();
    } catch (exception) {
      state = state.copyWith(
        status: BodyMetricsStatus.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> deleteMeasurement(String measurementId) async {
    try {
      await _repository.deleteMeasurement(measurementId);
      await loadMeasurements();
    } catch (exception) {
      state = state.copyWith(
        status: BodyMetricsStatus.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> updateComposition({
    required String compositionId,
    double? bodyFat,
    double? skeletalMuscle,
    double? fatFreeMass,
    double? subcutaneousFat,
    int? visceralFat,
    double? bodyWater,
    double? muscleMass,
    double? boneMass,
    double? protein,
    int? bmr,
    String? notes,
  }) async {
    try {
      await _repository.updateComposition(
        compositionId: compositionId,
        bodyFat: bodyFat,
        skeletalMuscle: skeletalMuscle,
        fatFreeMass: fatFreeMass,
        subcutaneousFat: subcutaneousFat,
        visceralFat: visceralFat,
        bodyWater: bodyWater,
        muscleMass: muscleMass,
        boneMass: boneMass,
        protein: protein,
        bmr: bmr,
        notes: notes,
      );
      await loadCompositions();
    } catch (exception) {
      state = state.copyWith(
        status: BodyMetricsStatus.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> deleteComposition(String compositionId) async {
    try {
      await _repository.deleteComposition(compositionId);
      await loadCompositions();
    } catch (exception) {
      state = state.copyWith(
        status: BodyMetricsStatus.error,
        errorMessage: exception.toString(),
      );
    }
  }
}
