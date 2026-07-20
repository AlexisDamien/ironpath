import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/training_session.dart';
import '../../domain/models/set_target.dart';
import '../providers/provider_rest_timer.dart';
import '../../../../core/widgets/component_rest_timer.dart';
import '../../../../core/utils/format_duration.dart';

typedef LogSetCallback = void Function({
  required int setOrder,
  required int? reps,
  required double? weightKg,
  required int? restSeconds,
  required bool isWarmup,
});

class CardActiveSessionExercise extends StatelessWidget {
  final String exerciseKey;
  final String exerciseName;
  final String? muscleGroup;
  final List<SetTarget> plannedSets;
  final List<ExerciseSet> loggedSets;
  final LogSetCallback onLogSet;

  const CardActiveSessionExercise({
    super.key,
    required this.exerciseKey,
    required this.exerciseName,
    this.muscleGroup,
    required this.plannedSets,
    required this.loggedSets,
    required this.onLogSet,
  });

  ExerciseSet? _loggedFor(int setOrder) {
    for (final set in loggedSets) {
      if (set.setOrder == setOrder) return set;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final totalSets = plannedSets.length;
    final doneCount = loggedSets.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          exerciseName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$doneCount/$totalSets séries'
          '${muscleGroup != null ? ' • $muscleGroup' : ''}',
        ),
        initiallyExpanded: doneCount < totalSets,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: plannedSets.map((plannedSet) {
                return _SetRow(
                  setId: '$exerciseKey-${plannedSet.setOrder}',
                  setOrder: plannedSet.setOrder,
                  plannedReps: plannedSet.targetReps,
                  plannedWeight: plannedSet.targetWeight,
                  plannedRestSeconds: plannedSet.restSeconds,
                  plannedIsWarmup: plannedSet.isWarmup,
                  logged: _loggedFor(plannedSet.setOrder),
                  onLogSet: onLogSet,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends ConsumerStatefulWidget {
  final String setId;
  final int setOrder;
  final int? plannedReps;
  final double? plannedWeight;
  final int? plannedRestSeconds;
  final bool plannedIsWarmup;
  final ExerciseSet? logged;
  final LogSetCallback onLogSet;

  const _SetRow({
    required this.setId,
    required this.setOrder,
    this.plannedReps,
    this.plannedWeight,
    this.plannedRestSeconds,
    this.plannedIsWarmup = false,
    this.logged,
    required this.onLogSet,
  });

  @override
  ConsumerState<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends ConsumerState<_SetRow> {
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController(
      text: (widget.logged?.reps ?? widget.plannedReps)?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: (widget.logged?.weightKg ?? widget.plannedWeight)?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _validate() {
    final timerState = ref.read(providerRestTimer);
    int? actualRestSeconds = widget.plannedRestSeconds;

    if (timerState.activeOwnerId == widget.setId) {
      actualRestSeconds = timerState.isOvertime
          ? timerState.totalSeconds + timerState.overtimeSeconds
          : timerState.totalSeconds - timerState.remainingSeconds;
      ref.read(providerRestTimer.notifier).clear();
    }

    widget.onLogSet(
      setOrder: widget.setOrder,
      reps: int.tryParse(_repsController.text),
      weightKg: double.tryParse(_weightController.text),
      restSeconds: actualRestSeconds,
      isWarmup: widget.plannedIsWarmup,
    );
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.logged != null && !_isEditing;
    final isWarmup = widget.logged?.isWarmup ?? widget.plannedIsWarmup;

    return Semantics(
      container: true,
      label: 'Série ${widget.setOrder}${isWarmup ? ', échauffement' : ''}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 26,
                  child: Text(
                    '${widget.setOrder}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isDone)
                  Expanded(
                    child: Text(
                      '${widget.logged!.reps ?? '-'} reps • ${widget.logged!.weightKg ?? '-'} kg',
                      style: const TextStyle(fontSize: 15),
                    ),
                  )
                else ...[
                  SizedBox(
                    width: 72,
                    child: TextField(
                      controller: _repsController,
                      decoration: const InputDecoration(labelText: 'Reps'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 84,
                    child: TextField(
                      controller: _weightController,
                      decoration: const InputDecoration(labelText: 'Kg'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isWarmup) ...[
                      Tooltip(
                        message: 'Série d\'échauffement',
                        child: Icon(
                          Icons.local_fire_department,
                          size: 18,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (!isDone && widget.plannedRestSeconds != null)
                      ComponentRestTimer(
                        id: widget.setId,
                        initialSeconds: widget.plannedRestSeconds!,
                      )
                    else if (isDone)
                      Text(
                        '${formatRestDuration(widget.logged!.restSeconds)} repos',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: isDone
                      ? IconButton(
                          icon: Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          tooltip: 'Série validée, appuyer pour modifier',
                          onPressed: () => setState(() => _isEditing = true),
                        )
                      : IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          tooltip: 'Valider la série',
                          onPressed: _validate,
                        ),
                ),
              ],
            ),
            const Divider(height: 16),
          ],
        ),
      ),
    );
  }
}
