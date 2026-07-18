import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/workout_program.dart';
import '../../domain/models/training_session.dart';
import '../../../../core/widgets/component_rest_timer.dart';
import '../providers/provider_rest_timer.dart';

String formatRestDuration(int? totalSeconds) {
  if (totalSeconds == null) return '-';
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  if (minutes > 0) {
    return '${minutes}min${seconds.toString().padLeft(2, '0')}s';
  }
  return '${seconds}s';
}

typedef LogSetCallback = void Function({
  required int setOrder,
  required int? reps,
  required double? weightKg,
  required int? restSeconds,
  required bool isWarmup,
});

class CardActiveSessionExercise extends StatelessWidget {
  final String exerciseName;
  final String? muscleGroup;
  final ProgramExercise programExercise;
  final List<ExerciseSet> loggedSets;
  final LogSetCallback onLogSet;

  const CardActiveSessionExercise({
    super.key,
    required this.exerciseName,
    this.muscleGroup,
    required this.programExercise,
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
    final totalSets = programExercise.sets.length;
    final doneCount = loggedSets.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(exerciseName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '$doneCount/$totalSets séries'
          '${muscleGroup != null ? ' • $muscleGroup' : ''}',
        ),
        initiallyExpanded: doneCount < totalSets,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: programExercise.sets.map((plannedSet) {
                return _SetRow(
                  setId: '${programExercise.id}-${plannedSet.setOrder}',
                  setOrder: plannedSet.setOrder,
                  plannedReps: plannedSet.targetReps,
                  plannedWeight: plannedSet.targetWeight,
                  plannedRestSeconds: plannedSet.restSeconds,
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
  final ExerciseSet? logged;
  final LogSetCallback onLogSet;

  const _SetRow({
    required this.setId,
    required this.setOrder,
    this.plannedReps,
    this.plannedWeight,
    this.plannedRestSeconds,
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
    }

    widget.onLogSet(
      setOrder: widget.setOrder,
      reps: int.tryParse(_repsController.text),
      weightKg: double.tryParse(_weightController.text),
      restSeconds: actualRestSeconds,
      isWarmup: false,
    );
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.logged != null && !_isEditing;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text('${widget.setOrder}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 6),
          if (isDone) ...[
            Expanded(
              child: Text(
                '${widget.logged!.reps ?? '-'} reps • ${widget.logged!.weightKg ?? '-'} kg • ${formatRestDuration(widget.logged!.restSeconds)} repos',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () => setState(() => _isEditing = true),
              visualDensity: VisualDensity.compact,
            ),
          ] else ...[
            SizedBox(
              width: 55,
              child: TextField(
                controller: _repsController,
                decoration:
                    const InputDecoration(labelText: 'Reps', isDense: true),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 65,
              child: TextField(
                controller: _weightController,
                decoration:
                    const InputDecoration(labelText: 'Kg', isDense: true),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const Spacer(),
            if (widget.plannedRestSeconds != null)
              ComponentRestTimer(
                id: widget.setId,
                initialSeconds: widget.plannedRestSeconds!,
              ),
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: _validate,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}
