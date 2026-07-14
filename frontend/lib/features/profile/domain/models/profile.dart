class Profile {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? birthDate;
  final double? height;
  final String? gender;
  final String? objective;

  Profile({
    required this.id,
    this.firstName,
    this.lastName,
    this.username,
    this.birthDate,
    this.height,
    this.gender,
    this.objective,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'],
      birthDate: json['birthDate'],
      height: json['height']?.toDouble(),
      gender: json['gender'],
      objective: json['objective'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'birthDate': birthDate,
      'height': height,
      'gender': gender,
      'objective': objective,
    };
  }
}
