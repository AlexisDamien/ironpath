import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/models/set_target.dart';

void main() {
  group('SetTarget', () {
    test('isWarmup defaults to false', () {
      final target = SetTarget(setOrder: 1);

      expect(target.isWarmup, isFalse);
    });

    test('optional fields default to null', () {
      final target = SetTarget(setOrder: 1);

      expect(target.targetReps, isNull);
      expect(target.targetWeight, isNull);
      expect(target.restSeconds, isNull);
    });

    test('stores all provided values', () {
      final target = SetTarget(
        setOrder: 3,
        targetReps: 8,
        targetWeight: 100,
        restSeconds: 120,
        isWarmup: true,
      );

      expect(target.setOrder, 3);
      expect(target.targetReps, 8);
      expect(target.targetWeight, 100);
      expect(target.restSeconds, 120);
      expect(target.isWarmup, isTrue);
    });
  });
}
