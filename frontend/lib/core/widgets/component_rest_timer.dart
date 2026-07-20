import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/training/presentation/providers/provider_rest_timer.dart';
import '../../features/training/presentation/screens/screen_rest_timer.dart';
import '../ui/app_theme.dart';
import '../utils/format_duration.dart';

class ComponentRestTimer extends ConsumerWidget {
  final String id;
  final int initialSeconds;

  const ComponentRestTimer({
    super.key,
    required this.id,
    required this.initialSeconds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(providerRestTimer);
    final notifier = ref.read(providerRestTimer.notifier);
    final isOwner = timerState.activeOwnerId == id;
    final isOvertime = isOwner && timerState.isOvertime;

    final displayText = isOwner
        ? (isOvertime
              ? '+${formatClockDuration(timerState.overtimeSeconds)}'
              : formatClockDuration(timerState.remainingSeconds))
        : formatClockDuration(initialSeconds);

    final color = isOvertime
        ? Theme.of(context).colorScheme.error
        : (isOwner
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface);

    final semanticLabel = isOwner
        ? (isOvertime
              ? 'Temps de repos. Dépassement de ${formatClockDuration(timerState.overtimeSeconds)}.'
              : 'Temps de repos restant : ${formatClockDuration(timerState.remainingSeconds)}.')
        : 'Temps de repos planifié : ${formatClockDuration(initialSeconds)}.';

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: IronSpacing.minTapTarget,
        minHeight: IronSpacing.minTapTarget,
      ),
      child: Semantics(
        button: true,
        label: semanticLabel,
        hint: isOwner
            ? 'Ouvrir le minuteur en plein écran'
            : 'Démarrer et ouvrir le minuteur',
        child: InkWell(
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 18, color: color),
                const SizedBox(width: 4),
                Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.open_in_full, size: 14, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
