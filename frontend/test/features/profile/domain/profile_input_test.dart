import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/profile/domain/models/profile_input.dart';

void main() {
  group('ProfileInput.toJson', () {
    test('serializes all provided fields', () {
      const input = ProfileInput(
        firstName: 'Alexis',
        lastName: 'Damien',
        username: 'alexisd',
        birthDate: '2000-01-15',
        height: 180.0,
        gender: 'M',
        objective: 'MUSCLE_GAIN',
      );

      final json = input.toJson();

      expect(json['firstName'], 'Alexis');
      expect(json['lastName'], 'Damien');
      expect(json['username'], 'alexisd');
      expect(json['birthDate'], '2000-01-15');
      expect(json['height'], 180.0);
      expect(json['gender'], 'M');
      expect(json['objective'], 'MUSCLE_GAIN');
    });

    test('serializes unset fields as null rather than omitting them', () {
      const input = ProfileInput();

      final json = input.toJson();

      expect(json.containsKey('firstName'), isTrue);
      expect(json['firstName'], isNull);
      expect(json.containsKey('height'), isTrue);
      expect(json['height'], isNull);
      expect(json.length, 7);
    });
  });
}
