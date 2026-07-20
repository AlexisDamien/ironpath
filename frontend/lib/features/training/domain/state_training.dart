import '../../../core/constants/enums.dart';
import 'models/exercise.dart';
import 'models/training_session.dart';
import 'models/workout_program.dart';

export '../../../core/constants/enums.dart' show StatusTraining;

class StateTraining {
  final StatusTraining status;
  final List<WorkoutProgram> programs;
  final TrainingSession? activeSession;
  final List<TrainingSession> sessionHistory;
  final String? errorMessage;
  final List<Exercise> exercises;

  const StateTraining({
    this.status = StatusTraining.idle,
    this.programs = const [],
    this.activeSession,
    this.sessionHistory = const [],
    this.errorMessage,
    this.exercises = const [],
  });

  StateTraining copyWith({
    StatusTraining? status,
    List<WorkoutProgram>? programs,
    TrainingSession? activeSession,
    bool clearActiveSession = false,
    List<TrainingSession>? sessionHistory,
    String? errorMessage,
    List<Exercise>? exercises,
    bool clearErrorMessage = false,
  }) {
    return StateTraining(
      status: status ?? this.status,
      programs: programs ?? this.programs,
      activeSession:
          clearActiveSession ? null : activeSession ?? this.activeSession,
      sessionHistory: sessionHistory ?? this.sessionHistory,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      exercises: exercises ?? this.exercises,
    );
  }
}
