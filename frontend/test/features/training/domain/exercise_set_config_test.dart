import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/models/exercise_set_config.dart';

void main() {
  group('ExerciseSetConfig', () {
    test('isWarmup defaults to false', () {
      final config = ExerciseSetConfig(setOrder: 1);

      expect(config.isWarmup, isFalse);
    });

    test('optional fields default to null', () {
      final config = ExerciseSetConfig(setOrder: 1);

      expect(config.targetReps, isNull);
      expect(config.targetWeight, isNull);
      expect(config.restSeconds, isNull);
    });

    test('stores all provided values', () {
      final config = ExerciseSetConfig(
        setOrder: 2,
        targetReps: 12,
        targetWeight: 60.5,
        restSeconds: 90,
        isWarmup: true,
      );

      expect(config.setOrder, 2);
      expect(config.targetReps, 12);
      expect(config.targetWeight, 60.5);
      expect(config.restSeconds, 90);
      expect(config.isWarmup, isTrue);
    });
  });
}
