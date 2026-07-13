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
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => ProgramExercise.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class ProgramExercise {
  final String id;
  final String exerciseId;
  final int exerciseOrder;
  final int? targetSets;
  final int? targetReps;
  final double? targetWeight;
  final int? restSeconds;

  ProgramExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseOrder,
    this.targetSets,
    this.targetReps,
    this.targetWeight,
    this.restSeconds,
  });

  factory ProgramExercise.fromJson(Map<String, dynamic> json) {
    return ProgramExercise(
      id: json['id'],
      exerciseId: json['exerciseId'],
      exerciseOrder: json['exerciseOrder'],
      targetSets: json['targetSets'],
      targetReps: json['targetReps'],
      targetWeight: json['targetWeight']?.toDouble(),
      restSeconds: json['restSeconds'],
    );
  }
}