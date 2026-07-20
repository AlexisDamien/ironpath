String formatClockDuration(int totalSeconds) {
  final safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
  final minutes = safeSeconds ~/ 60;
  final seconds = safeSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String formatRestDuration(int? totalSeconds) {
  if (totalSeconds == null) {
    return '-';
  }

  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;

  if (minutes > 0) {
    return '${minutes}min${seconds.toString().padLeft(2, '0')}s';
  }

  return '${seconds}s';
}
