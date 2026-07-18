class StateRestTimer {
  final int totalSeconds;
  final int remainingSeconds;
  final int overtimeSeconds;
  final bool isRunning;
  final String? activeOwnerId;

  const StateRestTimer({
    this.totalSeconds = 0,
    this.remainingSeconds = 0,
    this.overtimeSeconds = 0,
    this.isRunning = false,
    this.activeOwnerId,
  });

  bool get isActive => totalSeconds > 0;
  bool get isOvertime => isActive && remainingSeconds == 0;

  StateRestTimer copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    int? overtimeSeconds,
    bool? isRunning,
    String? activeOwnerId,
  }) {
    return StateRestTimer(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      overtimeSeconds: overtimeSeconds ?? this.overtimeSeconds,
      isRunning: isRunning ?? this.isRunning,
      activeOwnerId: activeOwnerId ?? this.activeOwnerId,
    );
  }
}
