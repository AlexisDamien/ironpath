import 'models/exercise.dart';
import 'models/workout_program.dart';
import 'models/training_session.dart';

enum TrainingStatus { idle, loading, success, error }

class TrainingState {
  final TrainingStatus status;
  final List<WorkoutProgram> programs;
  final TrainingSession? activeSession;
  final List<TrainingSession> sessionHistory;
  final String? errorMessage;
  final List<Exercise> exercises;

  const TrainingState({
    this.status = TrainingStatus.idle,
    this.programs = const [],
    this.activeSession,
    this.sessionHistory = const [],
    this.errorMessage,
    this.exercises = const [],
  });

  TrainingState copyWith({
    TrainingStatus? status,
    List<WorkoutProgram>? programs,
    TrainingSession? activeSession,
    bool clearActiveSession = false,
    List<TrainingSession>? sessionHistory,
    String? errorMessage,
    List<Exercise>? exercises,
  }) {
    return TrainingState(
      status: status ?? this.status,
      programs: programs ?? this.programs,
      activeSession:
          clearActiveSession ? null : activeSession ?? this.activeSession,
      sessionHistory: sessionHistory ?? this.sessionHistory,
      errorMessage: errorMessage ?? this.errorMessage,
      exercises: exercises ?? this.exercises,
    );
  }
}
