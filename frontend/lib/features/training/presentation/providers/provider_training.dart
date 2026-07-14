import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repository_training.dart';
import '../../domain/models/exercise_config.dart';
import '../../domain/state_training.dart';

final providerTrainingRepository = Provider<RepositoryTraining>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RepositoryTraining(apiClient);
});

final providerTraining =
    StateNotifierProvider<ProviderTrainingNotifier, StateTraining>((ref) {
  final repository = ref.watch(providerTrainingRepository);
  return ProviderTrainingNotifier(repository);
});

class ProviderTrainingNotifier extends StateNotifier<StateTraining> {
  final RepositoryTraining _repository;

  ProviderTrainingNotifier(this._repository) : super(const StateTraining());

  Future<void> loadPrograms() async {
    state = state.copyWith(status: StatusTraining.loading);
    try {
      final programs = await _repository.getPrograms();
      state = state.copyWith(
        status: StatusTraining.success,
        programs: programs,
      );
    } catch (exception) {
      state = state.copyWith(
        status: StatusTraining.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> createProgram({
    required String name,
    String? description,
    List<ExerciseConfig> exercises = const [],
  }) async {
    state = state.copyWith(status: StatusTraining.loading);
    try {
      await _repository.createProgram(
        name: name,
        description: description,
        exercises: exercises,
      );
      await loadPrograms();
    } catch (exception) {
      state = state.copyWith(
        status: StatusTraining.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> deleteProgram(String programId) async {
    try {
      await _repository.deleteProgram(programId);
      await loadPrograms();
    } catch (exception) {
      state = state.copyWith(
        status: StatusTraining.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> startSession({String? programId, String? name}) async {
    state = state.copyWith(status: StatusTraining.loading);
    try {
      final session = await _repository.startSession(
        programId: programId,
        name: name,
      );
      state = state.copyWith(
        status: StatusTraining.success,
        activeSession: session,
      );
    } catch (exception) {
      state = state.copyWith(
        status: StatusTraining.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> addSet({
    required String sessionId,
    required String exerciseId,
    required int setOrder,
    int? reps,
    double? weightKg,
    int? restSeconds,
    bool isWarmup = false,
  }) async {
    try {
      final updatedSession = await _repository.addSet(
        sessionId: sessionId,
        exerciseId: exerciseId,
        setOrder: setOrder,
        reps: reps,
        weightKg: weightKg,
        restSeconds: restSeconds,
        isWarmup: isWarmup,
      );
      state = state.copyWith(activeSession: updatedSession);
    } catch (exception) {
      state = state.copyWith(
        status: StatusTraining.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> endSession(String sessionId) async {
    try {
      await _repository.endSession(sessionId);
      state = state.copyWith(clearActiveSession: true);
      await loadPrograms();
    } catch (exception) {
      state = state.copyWith(
        status: StatusTraining.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> loadSessionHistory() async {
    try {
      final sessionHistory = await _repository.getSessionHistory();
      state = state.copyWith(sessionHistory: sessionHistory);
    } catch (exception) {
      state = state.copyWith(
        status: StatusTraining.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> loadExercises({String? search, String? muscleGroup}) async {
    try {
      final exercises = await _repository.getExercises(
        search: search,
        muscleGroup: muscleGroup,
      );
      state = state.copyWith(exercises: exercises);
    } catch (exception) {
      state = state.copyWith(
        status: StatusTraining.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> updateProgram({
    required String programId,
    required String name,
    String? description,
    List<ExerciseConfig> exercises = const [],
  }) async {
    state = state.copyWith(status: StatusTraining.loading);
    try {
      await _repository.updateProgram(
        programId: programId,
        name: name,
        description: description,
        exercises: exercises,
      );
      await loadPrograms();
    } catch (exception) {
      state = state.copyWith(
        status: StatusTraining.error,
        errorMessage: exception.toString(),
      );
    }
  }
}
