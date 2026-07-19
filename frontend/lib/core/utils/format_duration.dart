String formatRestDuration(int? totalSeconds) {
  if (totalSeconds == null) return '-';
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  if (minutes > 0) {
    return '${minutes}min${seconds.toString().padLeft(2, '0')}s';
  }
  return '${seconds}s';
}
