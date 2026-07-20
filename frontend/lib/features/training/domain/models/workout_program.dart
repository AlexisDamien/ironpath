class WorkoutProgram {
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final List<ProgramExercise> exercises;

  WorkoutProgram({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.exercises,
  });

  factory WorkoutProgram.fromJson(Map<String, dynamic> json) {
    return WorkoutProgram(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'] ?? false,
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map((e) => ProgramExercise.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ProgramExerciseSetModel {
  final String id;
  final int setOrder;
  final int? targetReps;
  final double? targetWeight;
  final int? restSeconds;
  final bool isWarmup;

  ProgramExerciseSetModel({
    required this.id,
    required this.setOrder,
    this.targetReps,
    this.targetWeight,
    this.restSeconds,
    this.isWarmup = false,
  });

  factory ProgramExerciseSetModel.fromJson(Map<String, dynamic> json) {
    return ProgramExerciseSetModel(
      id: json['id'],
      setOrder: json['setOrder'],
      targetReps: json['targetReps'],
      targetWeight: json['targetWeightKg']?.toDouble(),
      restSeconds: json['restSeconds'],
      isWarmup: json['isWarmup'] ?? false,
    );
  }
}

class ProgramExercise {
  final String id;
  final String exerciseId;
  final int exerciseOrder;
  final bool sameConfigForAllSets;
  final List<ProgramExerciseSetModel> sets;

  ProgramExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseOrder,
    required this.sameConfigForAllSets,
    required this.sets,
  });

  factory ProgramExercise.fromJson(Map<String, dynamic> json) {
    return ProgramExercise(
      id: json['id'],
      exerciseId: json['exerciseId'],
      exerciseOrder: json['exerciseOrder'],
      sameConfigForAllSets: json['sameConfigForAllSets'] ?? true,
      sets:
          (json['sets'] as List<dynamic>?)
              ?.map((s) => ProgramExerciseSetModel.fromJson(s))
              .toList() ??
          [],
    );
  }
}
