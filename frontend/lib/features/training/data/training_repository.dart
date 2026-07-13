import '../../../core/network/api_client.dart';
import '../domain/models/exercise.dart';
import '../domain/models/workout_program.dart';
import '../domain/models/training_session.dart';

class TrainingRepository {
  final ApiClient _apiClient;

  TrainingRepository(this._apiClient);

  Future<List<WorkoutProgram>> getPrograms() async {
    final response = await _apiClient.get('/training/programs');
    return (response.data as List)
        .map((e) => WorkoutProgram.fromJson(e))
        .toList();
  }

  Future<WorkoutProgram> createProgram({
    required String name,
    String? description,
    List<Exercise> exercises = const [],
  }) async {
    final response = await _apiClient.post('/training/programs', data: {
      'name': name,
      'description': description,
      'exercises': exercises
          .asMap()
          .entries
          .map((entry) => {
                'exerciseId': entry.value.id,
                'exerciseOrder': entry.key + 1,
                'targetSets': 3,
                'targetReps': 10,
                'restSeconds': 90,
              })
          .toList(),
    });
    return WorkoutProgram.fromJson(response.data);
  }

  Future<WorkoutProgram> updateProgram({
    required String programId,
    required String name,
    String? description,
    List<Exercise> exercises = const [],
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
                  'exerciseId': entry.value.id,
                  'exerciseOrder': entry.key + 1,
                  'targetSets': 3,
                  'targetReps': 10,
                  'restSeconds': 90,
                })
            .toList(),
      },
    );
    return WorkoutProgram.fromJson(response.data);
  }

  Future<void> deleteProgram(String id) async {
    await _apiClient.delete('/training/programs/$id');
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
        .map((e) => TrainingSession.fromJson(e))
        .toList();
  }

  Future<List<Exercise>> getExercises(
      {String? search, String? muscleGroup}) async {
    final Map<String, dynamic> queryParameters = {};
    if (search != null) queryParameters['search'] = search;
    if (muscleGroup != null) queryParameters['muscleGroup'] = muscleGroup;

    final response = await _apiClient.get(
      '/exercises',
      queryParameters: queryParameters,
    );
    return (response.data as List)
        .map((exerciseJson) => Exercise.fromJson(exerciseJson))
        .toList();
  }
}
