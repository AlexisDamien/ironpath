class BodyMeasurement {
  final String id;
  final double? weight;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? leftArm;
  final double? rightArm;
  final double? leftThigh;
  final double? rightThigh;
  final double? leftCalf;
  final double? rightCalf;
  final String? notes;
  final DateTime recordedAt;
  final bool archived;

  BodyMeasurement({
    required this.id,
    this.weight,
    this.chest,
    this.waist,
    this.hips,
    this.leftArm,
    this.rightArm,
    this.leftThigh,
    this.rightThigh,
    this.leftCalf,
    this.rightCalf,
    this.notes,
    required this.recordedAt,
    this.archived = false,
  });

  bool get isEditable => !archived;

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'],
      weight: json['weight']?.toDouble(),
      chest: json['chest']?.toDouble(),
      waist: json['waist']?.toDouble(),
      hips: json['hips']?.toDouble(),
      leftArm: json['leftArm']?.toDouble(),
      rightArm: json['rightArm']?.toDouble(),
      leftThigh: json['leftThigh']?.toDouble(),
      rightThigh: json['rightThigh']?.toDouble(),
      leftCalf: json['leftCalf']?.toDouble(),
      rightCalf: json['rightCalf']?.toDouble(),
      notes: json['notes'],
      recordedAt: DateTime.parse(json['recordedAt']),
      archived: json['archived'] ?? false,
    );
  }
}
