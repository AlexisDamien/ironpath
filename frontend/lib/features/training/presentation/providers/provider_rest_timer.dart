import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/state_rest_timer.dart';

final providerRestTimer =
    StateNotifierProvider<ProviderRestTimerNotifier, StateRestTimer>((ref) {
      return ProviderRestTimerNotifier();
    });

class ProviderRestTimerNotifier extends StateNotifier<StateRestTimer> {
  Timer? _timer;

  ProviderRestTimerNotifier() : super(const StateRestTimer());

  void start(int seconds, String ownerId) {
    _timer?.cancel();
    state = StateRestTimer(
      totalSeconds: seconds,
      remainingSeconds: seconds,
      overtimeSeconds: 0,
      isRunning: true,
      activeOwnerId: ownerId,
    );
    _tick();
  }

  void _tick() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        state = state.copyWith(overtimeSeconds: state.overtimeSeconds + 1);
      }
    });
  }

  void togglePlayPause() {
    if (state.isRunning) {
      _timer?.cancel();
      state = state.copyWith(isRunning: false);
    } else {
      state = state.copyWith(isRunning: true);
      _tick();
    }
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      remainingSeconds: state.totalSeconds,
      overtimeSeconds: 0,
      isRunning: false,
    );
  }

  void clear() {
    _timer?.cancel();
    state = const StateRestTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void setDuration(int seconds, String ownerId) {
    if (seconds < 0) return;
    final wasRunning = state.isRunning;
    _timer?.cancel();
    state = StateRestTimer(
      totalSeconds: seconds,
      remainingSeconds: seconds,
      overtimeSeconds: 0,
      isRunning: false,
      activeOwnerId: ownerId,
    );
    if (wasRunning) {
      state = state.copyWith(isRunning: true);
      _tick();
    }
  }
}
