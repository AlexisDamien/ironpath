import '../../../core/network/api_client.dart';
import '../domain/models/body_measurement.dart';
import '../domain/models/body_composition.dart';

class RepositoryBodyMetrics {
  final ApiClient _apiClient;

  RepositoryBodyMetrics(this._apiClient);

  Future<List<BodyMeasurement>> getMeasurements() async {
    final response = await _apiClient.get('/bodymetrics/measurements');
    return (response.data as List)
        .map((measurementData) => BodyMeasurement.fromJson(measurementData))
        .toList();
  }

  Future<BodyMeasurement> saveMeasurement({
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
    final response = await _apiClient.post('/bodymetrics/measurements', data: {
      'weight': weight,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'leftArm': leftArm,
      'rightArm': rightArm,
      'leftThigh': leftThigh,
      'rightThigh': rightThigh,
      'leftCalf': leftCalf,
      'rightCalf': rightCalf,
      'notes': notes,
      'recordedAt': recordedAt?.toIso8601String(),
    });
    return BodyMeasurement.fromJson(response.data);
  }

  Future<List<BodyComposition>> getCompositions() async {
    final response = await _apiClient.get('/bodymetrics/compositions');
    return (response.data as List)
        .map((compositionData) => BodyComposition.fromJson(compositionData))
        .toList();
  }

  Future<BodyComposition> saveComposition({
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
    final response = await _apiClient.post('/bodymetrics/compositions', data: {
      'bodyFat': bodyFat,
      'skeletalMuscle': skeletalMuscle,
      'fatFreeMass': fatFreeMass,
      'subcutaneousFat': subcutaneousFat,
      'visceralFat': visceralFat,
      'bodyWater': bodyWater,
      'muscleMass': muscleMass,
      'boneMass': boneMass,
      'protein': protein,
      'bmr': bmr,
      'notes': notes,
      'recordedAt': recordedAt?.toIso8601String(),
    });
    return BodyComposition.fromJson(response.data);
  }

  Future<BodyMeasurement> updateMeasurement({
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
    final response = await _apiClient.put(
      '/bodymetrics/measurements/$measurementId',
      data: {
        'weight': weight,
        'chest': chest,
        'waist': waist,
        'hips': hips,
        'leftArm': leftArm,
        'rightArm': rightArm,
        'leftThigh': leftThigh,
        'rightThigh': rightThigh,
        'leftCalf': leftCalf,
        'rightCalf': rightCalf,
        'notes': notes,
      },
    );
    return BodyMeasurement.fromJson(response.data);
  }

  Future<void> deleteMeasurement(String measurementId) async {
    await _apiClient.delete('/bodymetrics/measurements/$measurementId');
  }

  Future<BodyComposition> updateComposition({
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
    final response = await _apiClient.put(
      '/bodymetrics/compositions/$compositionId',
      data: {
        'bodyFat': bodyFat,
        'skeletalMuscle': skeletalMuscle,
        'fatFreeMass': fatFreeMass,
        'subcutaneousFat': subcutaneousFat,
        'visceralFat': visceralFat,
        'bodyWater': bodyWater,
        'muscleMass': muscleMass,
        'boneMass': boneMass,
        'protein': protein,
        'bmr': bmr,
        'notes': notes,
      },
    );
    return BodyComposition.fromJson(response.data);
  }

  Future<void> deleteComposition(String compositionId) async {
    await _apiClient.delete('/bodymetrics/compositions/$compositionId');
  }
}
