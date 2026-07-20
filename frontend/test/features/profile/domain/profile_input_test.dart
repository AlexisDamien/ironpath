import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/profile/domain/models/profile_input.dart';

void main() {
  test('toJson expose tous les champs attendus', () {
    const input = ProfileInput(
      firstName: 'Alex',
      lastName: 'Martin',
      username: 'alexmartin',
      birthDate: '1990-02-03',
      height: 178,
      gender: 'MALE',
      objective: 'STRENGTH',
    );

    expect(input.toJson(), {
      'firstName': 'Alex',
      'lastName': 'Martin',
      'username': 'alexmartin',
      'birthDate': '1990-02-03',
      'height': 178,
      'gender': 'MALE',
      'objective': 'STRENGTH',
    });
  });

  test('toJson conserve les valeurs nulles', () {
    expect(
      const ProfileInput().toJson().values.every((value) => value == null),
      isTrue,
    );
  });
}
