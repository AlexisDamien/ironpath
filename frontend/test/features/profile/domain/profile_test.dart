import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/profile/domain/models/profile.dart';

import '../../../helpers/fixtures.dart';

void main() {
  test('fromJson convertit tous les champs', () {
    final profile = Profile.fromJson(profileJson());

    expect(profile.id, 'profile-1');
    expect(profile.firstName, 'Alex');
    expect(profile.lastName, 'Martin');
    expect(profile.username, 'alexmartin');
    expect(profile.birthDate, '1990-02-03');
    expect(profile.height, 178.0);
    expect(profile.gender, 'MALE');
    expect(profile.objective, 'STRENGTH');
    expect(profile.isProfileComplete, isTrue);
  });

  test('profileComplete vaut false par défaut', () {
    final json = profileJson()..remove('profileComplete');
    expect(Profile.fromJson(json).isProfileComplete, isFalse);
  });
}
