import '../../../core/network/api_client.dart';
import '../domain/models/exercise.dart';
import '../domain/models/exercise_config.dart';
import '../domain/models/workout_program.dart';
import '../domain/models/training_session.dart';

class TrainingRepository {
  final ApiClient _apiClient;

  TrainingRepository(this._apiClient);

  Future<List<WorkoutProgram>> getPrograms() async {
    final response = await _apiClient.get('/training/programs');
    return (response.data as List)
        .map((programData) => WorkoutProgram.fromJson(programData))
        .toList();
  }

  Future<WorkoutProgram> createProgram({
    required String name,
    String? description,
    List<ExerciseConfig> exercises = const [],
  }) async {
    final response = await _apiClient.post('/training/programs', data: {
      'name': name,
      'description': description,
      'exercises': exercises
          .asMap()
          .entries
          .map((entry) => {
                'exerciseId': entry.value.exercise.id,
                'exerciseOrder': entry.key + 1,
                'targetSets': entry.value.targetSets,
                'targetReps': entry.value.targetReps,
                'targetWeightKg': entry.value.targetWeight,
                'restSeconds': entry.value.restSeconds,
              })
          .toList(),
    });
    return WorkoutProgram.fromJson(response.data);
  }

  Future<WorkoutProgram> updateProgram({
    required String programId,
    required String name,
    String? description,
    List<ExerciseConfig> exercises = const [],
  }) async {
    final response = await _apiClient.put(
      '/training/programs/$programId',
      data: {
        'name': name,
        'description': description,
        'exercises': exercises
            .asMap()
            .entries
            .map((entry) => {
                  'exerciseId': entry.value.exercise.id,
                  'exerciseOrder': entry.key + 1,
                  'targetSets': entry.value.targetSets,
                  'targetReps': entry.value.targetReps,
                  'targetWeightKg': entry.value.targetWeight,
                  'restSeconds': entry.value.restSeconds,
                })
            .toList(),
      },
    );
    return WorkoutProgram.fromJson(response.data);
  }

  Future<void> deleteProgram(String programId) async {
    await _apiClient.delete('/training/programs/$programId');
  }

  Future<TrainingSession> startSession({
    String? programId,
    String? name,
  }) async {
    final response = await _apiClient.post('/training/sessions', data: {
      'programId': programId,
      'name': name,
    });
    return TrainingSession.fromJson(response.data);
  }

  Future<TrainingSession> addSet({
    required String sessionId,
    required String exerciseId,
    required int setOrder,
    int? reps,
    double? weightKg,
    int? restSeconds,
    bool isWarmup = false,
  }) async {
    final response = await _apiClient.post(
      '/training/sessions/$sessionId/sets',
      data: {
        'exerciseId': exerciseId,
        'setOrder': setOrder,
        'reps': reps,
        'weightKg': weightKg,
        'restSeconds': restSeconds,
        'isWarmup': isWarmup,
      },
    );
    return TrainingSession.fromJson(response.data);
  }

  Future<TrainingSession> endSession(String sessionId) async {
    final response = await _apiClient.put(
      '/training/sessions/$sessionId/end',
    );
    return TrainingSession.fromJson(response.data);
  }

  Future<List<TrainingSession>> getSessionHistory() async {
    final response = await _apiClient.get('/training/sessions');
    return (response.data as List)
        .map((sessionData) => TrainingSession.fromJson(sessionData))
        .toList();
  }

  Future<List<Exercise>> getExercises({
    String? search,
    String? muscleGroup,
  }) async {
    final Map<String, dynamic> queryParameters = {};
    if (search != null) queryParameters['search'] = search;
    if (muscleGroup != null) queryParameters['muscleGroup'] = muscleGroup;

    final response = await _apiClient.get(
      '/exercises',
      queryParameters: queryParameters,
    );
    return (response.data as List)
        .map((exerciseData) => Exercise.fromJson(exerciseData))
        .toList();
  }
}
