import 'package:flutter/material.dart';
import '../../domain/models/exercise_config.dart';

class CardSelectedExercise extends StatelessWidget {
  final int index;
  final ExerciseConfig config;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const CardSelectedExercise({
    super.key,
    required this.index,
    required this.config,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: Icon(
            Icons.drag_handle,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        title: Text(
          config.exercise.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${config.sets.length} série${config.sets.length > 1 ? 's' : ''}'
          '${config.exercise.muscleGroup != null ? ' • ${config.exercise.muscleGroup}' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: onRemove,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final set in config.sets)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70,
                          child: Text(
                            'Série ${set.setOrder}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            [
                              if (set.targetReps != null)
                                '${set.targetReps} reps',
                              if (set.targetWeight != null)
                                '${set.targetWeight} kg',
                              if (set.restSeconds != null)
                                '${set.restSeconds}s repos',
                            ].join(' • '),
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
