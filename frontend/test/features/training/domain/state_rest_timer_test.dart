import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/training/domain/state_rest_timer.dart';

void main() {
  test('un timer sans durée est inactif', () {
    const state = StateRestTimer();
    expect(state.isActive, isFalse);
    expect(state.isOvertime, isFalse);
  });

  test('un timer arrivé à zéro est en dépassement', () {
    const state = StateRestTimer(totalSeconds: 90, remainingSeconds: 0);
    expect(state.isActive, isTrue);
    expect(state.isOvertime, isTrue);
  });

  test('copyWith conserve le propriétaire', () {
    const state = StateRestTimer(
      totalSeconds: 90,
      remainingSeconds: 60,
      activeOwnerId: 'set-1',
    );

    final copy = state.copyWith(remainingSeconds: 59);
    expect(copy.activeOwnerId, 'set-1');
    expect(copy.remainingSeconds, 59);
  });
}
