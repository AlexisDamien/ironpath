class ProfileInput {
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? birthDate;
  final double? height;
  final String? gender;
  final String? objective;

  const ProfileInput({
    this.firstName,
    this.lastName,
    this.username,
    this.birthDate,
    this.height,
    this.gender,
    this.objective,
  });

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
