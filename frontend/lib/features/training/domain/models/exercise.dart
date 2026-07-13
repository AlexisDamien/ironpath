class Exercise {
  final String id;
  final String name;
  final String? muscleGroup;
  final String? equipment;
  final String? description;

  Exercise({
    required this.id,
    required this.name,
    this.muscleGroup,
    this.equipment,
    this.description,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      muscleGroup: json['muscleGroup'],
      equipment: json['equipment'],
      description: json['description'],
    );
  }
}