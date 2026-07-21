import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/models/exercise.dart';

void main() {
  group('Exercise.fromJson', () {
    test('parses all fields when fully populated', () {
      final exercise = Exercise.fromJson({
        'id': 'ex-1',
        'name': 'Développé couché',
        'muscleGroup': 'Pectoraux',
        'equipment': 'Barre',
        'description': 'Exercice de base pour les pectoraux',
      });

      expect(exercise.id, 'ex-1');
      expect(exercise.name, 'Développé couché');
      expect(exercise.muscleGroup, 'Pectoraux');
      expect(exercise.equipment, 'Barre');
      expect(exercise.description, 'Exercice de base pour les pectoraux');
    });

    test('parses nullable fields as null when absent', () {
      final exercise = Exercise.fromJson({'id': 'ex-2', 'name': 'Squat'});

      expect(exercise.id, 'ex-2');
      expect(exercise.name, 'Squat');
      expect(exercise.muscleGroup, isNull);
      expect(exercise.equipment, isNull);
      expect(exercise.description, isNull);
    });
  });

  group('Exercise constructor', () {
    test('creates an instance with required fields only', () {
      final exercise = Exercise(id: 'ex-3', name: 'Traction');

      expect(exercise.id, 'ex-3');
      expect(exercise.name, 'Traction');
      expect(exercise.muscleGroup, isNull);
    });
  });
}
