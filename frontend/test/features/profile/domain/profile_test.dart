import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/profile/domain/models/profile.dart';

void main() {
  group('Profile.fromJson', () {
    test('parses all fields when fully populated', () {
      final profile = Profile.fromJson({
        'id': 'user-1',
        'firstName': 'Alexis',
        'lastName': 'Damien',
        'username': 'alexisd',
        'birthDate': '2000-01-15',
        'height': 180.0,
        'gender': 'M',
        'objective': 'MUSCLE_GAIN',
        'profileComplete': true,
      });

      expect(profile.id, 'user-1');
      expect(profile.firstName, 'Alexis');
      expect(profile.lastName, 'Damien');
      expect(profile.username, 'alexisd');
      expect(profile.birthDate, '2000-01-15');
      expect(profile.height, 180.0);
      expect(profile.gender, 'M');
      expect(profile.objective, 'MUSCLE_GAIN');
      expect(profile.isProfileComplete, isTrue);
    });

    test('defaults isProfileComplete to false when "profileComplete" absent',
        () {
      final profile = Profile.fromJson({'id': 'user-2'});

      expect(profile.isProfileComplete, isFalse);
      expect(profile.firstName, isNull);
      expect(profile.height, isNull);
    });

    test('converts numeric height from int to double', () {
      final profile = Profile.fromJson({'id': 'user-3', 'height': 175});

      expect(profile.height, 175.0);
      expect(profile.height, isA<double>());
    });
  });

  group('Profile constructor', () {
    test('isProfileComplete defaults to false', () {
      const profile = Profile(id: 'user-4');

      expect(profile.isProfileComplete, isFalse);
    });
  });
}
