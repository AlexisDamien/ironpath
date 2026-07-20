class TrainingSession {
  final String id;
  final String? name;
  final String status;
  final String? programId;
  final List<ExerciseSet> sets;
  final List<SessionPlannedExercise> plannedExercises;
  final DateTime startedAt;
  final DateTime? endedAt;

  TrainingSession({
    required this.id,
    this.name,
    required this.status,
    this.programId,
    required this.sets,
    required this.plannedExercises,
    required this.startedAt,
    this.endedAt,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      programId: json['programId'],
      sets:
          (json['sets'] as List<dynamic>?)
              ?.map((s) => ExerciseSet.fromJson(s))
              .toList() ??
          [],
      plannedExercises:
          (json['plannedExercises'] as List<dynamic>?)
              ?.map((e) => SessionPlannedExercise.fromJson(e))
              .toList() ??
          [],
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
    );
  }
}

class SessionPlannedSet {
  final String id;
  final int setOrder;
  final int? targetReps;
  final double? targetWeight;
  final int? restSeconds;
  final bool isWarmup;

  SessionPlannedSet({
    required this.id,
    required this.setOrder,
    this.targetReps,
    this.targetWeight,
    this.restSeconds,
    this.isWarmup = false,
  });

  factory SessionPlannedSet.fromJson(Map<String, dynamic> json) {
    return SessionPlannedSet(
      id: json['id'],
      setOrder: json['setOrder'],
      targetReps: json['targetReps'],
      targetWeight: json['targetWeightKg']?.toDouble(),
      restSeconds: json['restSeconds'],
      isWarmup: json['isWarmup'] ?? false,
    );
  }
}

class SessionPlannedExercise {
  final String id;
  final String exerciseId;
  final int exerciseOrder;
  final List<SessionPlannedSet> sets;

  SessionPlannedExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseOrder,
    required this.sets,
  });

  factory SessionPlannedExercise.fromJson(Map<String, dynamic> json) {
    return SessionPlannedExercise(
      id: json['id'],
      exerciseId: json['exerciseId'],
      exerciseOrder: json['exerciseOrder'],
      sets:
          (json['sets'] as List<dynamic>?)
              ?.map((s) => SessionPlannedSet.fromJson(s))
              .toList() ??
          [],
    );
  }
}

class ExerciseSet {
  final String id;
  final String exerciseId;
  final int setOrder;
  final int? reps;
  final double? weightKg;
  final int? restSeconds;
  final bool isWarmup;

  ExerciseSet({
    required this.id,
    required this.exerciseId,
    required this.setOrder,
    this.reps,
    this.weightKg,
    this.restSeconds,
    required this.isWarmup,
  });

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      id: json['id'],
      exerciseId: json['exerciseId'],
      setOrder: json['setOrder'],
      reps: json['reps'],
      weightKg: json['weightKg']?.toDouble(),
      restSeconds: json['restSeconds'],
      isWarmup: json['isWarmup'] ?? false,
    );
  }
}
