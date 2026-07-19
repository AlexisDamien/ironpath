class Profile {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? birthDate;
  final double? height;
  final String? gender;
  final String? objective;
  final bool isProfileComplete;

  const Profile({
    required this.id,
    this.firstName,
    this.lastName,
    this.username,
    this.birthDate,
    this.height,
    this.gender,
    this.objective,
    this.isProfileComplete = false,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      username: json['username'] as String?,
      birthDate: json['birthDate'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      gender: json['gender'] as String?,
      objective: json['objective'] as String?,
      isProfileComplete: json['profileComplete'] as bool? ?? false,
    );
  }
}
