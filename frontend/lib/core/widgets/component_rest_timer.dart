import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/training/presentation/providers/provider_rest_timer.dart';
import '../../features/training/presentation/screens/screen_rest_timer.dart';

class ComponentRestTimer extends ConsumerWidget {
  final String id;
  final int initialSeconds;

  const ComponentRestTimer({
    super.key,
    required this.id,
    required this.initialSeconds,
  });

  String _format(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(providerRestTimer);
    final notifier = ref.read(providerRestTimer.notifier);
    final isOwner = timerState.activeOwnerId == id;
    final isOvertime = isOwner && timerState.isOvertime;

    final displayText = isOwner
        ? (isOvertime
            ? '+${_format(timerState.overtimeSeconds)}'
            : _format(timerState.remainingSeconds))
        : _format(initialSeconds);

    final color = isOvertime
        ? Theme.of(context).colorScheme.error
        : (isOwner
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        if (!isOwner) {
          notifier.start(initialSeconds, id);
        }
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) =>
                ScreenRestTimer(initialSeconds: initialSeconds, id: id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              displayText,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(width: 3),
            Icon(Icons.open_in_full,
                size: 12, color: color.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}
