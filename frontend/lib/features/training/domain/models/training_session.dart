class TrainingSession {
  final String id;
  final String? name;
  final String status;
  final String? programId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<ExerciseSet> sets;

  TrainingSession({
    required this.id,
    this.name,
    required this.status,
    this.programId,
    required this.startedAt,
    this.endedAt,
    required this.sets,
  });

  bool get isActive => status == 'IN_PROGRESS';

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      programId: json['programId'],
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      sets: (json['sets'] as List<dynamic>?)
          ?.map((e) => ExerciseSet.fromJson(e))
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