class BodyComposition {
  final String id;
  final double? bodyFat;
  final double? skeletalMuscle;
  final double? fatFreeMass;
  final double? subcutaneousFat;
  final int? visceralFat;
  final double? bodyWater;
  final double? muscleMass;
  final double? boneMass;
  final double? protein;
  final int? bmr;
  final double? bmi;
  final int? metabolicAge;
  final String? notes;
  final DateTime recordedAt;
  final String source;
  final bool archived;

  BodyComposition({
    required this.id,
    this.bodyFat,
    this.skeletalMuscle,
    this.fatFreeMass,
    this.subcutaneousFat,
    this.visceralFat,
    this.bodyWater,
    this.muscleMass,
    this.boneMass,
    this.protein,
    this.bmr,
    this.bmi,
    this.metabolicAge,
    this.notes,
    required this.recordedAt,
    this.source = 'MANUAL',
    this.archived = false,
  });

  bool get isEditable => !archived;
  bool get isManual => source == 'MANUAL';

  factory BodyComposition.fromJson(Map<String, dynamic> json) {
    return BodyComposition(
      id: json['id'],
      bodyFat: json['bodyFat']?.toDouble(),
      skeletalMuscle: json['skeletalMuscle']?.toDouble(),
      fatFreeMass: json['fatFreeMass']?.toDouble(),
      subcutaneousFat: json['subcutaneousFat']?.toDouble(),
      visceralFat: json['visceralFat'],
      bodyWater: json['bodyWater']?.toDouble(),
      muscleMass: json['muscleMass']?.toDouble(),
      boneMass: json['boneMass']?.toDouble(),
      protein: json['protein']?.toDouble(),
      bmr: json['bmr'],
      bmi: json['bmi']?.toDouble(),
      metabolicAge: json['metabolicAge'],
      notes: json['notes'],
      recordedAt: DateTime.parse(json['recordedAt']),
      source: json['source'] ?? 'MANUAL',
      archived: json['archived'] ?? false,
    );
  }
}
