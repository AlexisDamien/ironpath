import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ironpath/features/training/presentation/providers/provider_rest_timer.dart';

void main() {
  test('start initialise puis décrémente le timer', () {
    fakeAsync((async) {
      final notifier = ProviderRestTimerNotifier();

      notifier.start(2, 'set-1');
      expect(notifier.state.remainingSeconds, 2);
      expect(notifier.state.isRunning, isTrue);
      expect(notifier.state.activeOwnerId, 'set-1');

      async.elapse(const Duration(seconds: 1));
      expect(notifier.state.remainingSeconds, 1);

      async.elapse(const Duration(seconds: 1));
      expect(notifier.state.remainingSeconds, 0);

      async.elapse(const Duration(seconds: 1));
      expect(notifier.state.overtimeSeconds, 1);
      notifier.dispose();
    });
  });

  test('togglePlayPause suspend et reprend le décompte', () {
    fakeAsync((async) {
      final notifier = ProviderRestTimerNotifier();
      notifier.start(3, 'set-1');

      notifier.togglePlayPause();
      async.elapse(const Duration(seconds: 2));
      expect(notifier.state.remainingSeconds, 3);
      expect(notifier.state.isRunning, isFalse);

      notifier.togglePlayPause();
      async.elapse(const Duration(seconds: 1));
      expect(notifier.state.remainingSeconds, 2);
      notifier.dispose();
    });
  });

  test('reset remet la durée initiale et arrête le timer', () {
    fakeAsync((async) {
      final notifier = ProviderRestTimerNotifier();
      notifier.start(3, 'set-1');
      async.elapse(const Duration(seconds: 2));

      notifier.reset();

      expect(notifier.state.remainingSeconds, 3);
      expect(notifier.state.overtimeSeconds, 0);
      expect(notifier.state.isRunning, isFalse);
      notifier.dispose();
    });
  });

  test('setDuration conserve l’état de lecture', () {
    fakeAsync((async) {
      final notifier = ProviderRestTimerNotifier();
      notifier.start(3, 'set-1');

      notifier.setDuration(10, 'set-2');

      expect(notifier.state.totalSeconds, 10);
      expect(notifier.state.remainingSeconds, 10);
      expect(notifier.state.isRunning, isTrue);
      expect(notifier.state.activeOwnerId, 'set-2');
      notifier.dispose();
    });
  });

  test('setDuration ignore une durée négative', () {
    final notifier = ProviderRestTimerNotifier();
    notifier.setDuration(-1, 'set-1');
    expect(notifier.state.totalSeconds, 0);
    notifier.dispose();
  });

  test('clear remet tout à zéro', () {
    final notifier = ProviderRestTimerNotifier();
    notifier.start(90, 'set-1');

    notifier.clear();

    expect(notifier.state.isActive, isFalse);
    expect(notifier.state.activeOwnerId, isNull);
    notifier.dispose();
  });
}
