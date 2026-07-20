import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../domain/models/exercise_config.dart';

enum _ExerciseAction { moveUp, moveDown, edit, remove }

class CardSelectedExercise extends StatelessWidget {
  final int index;
  final ExerciseConfig config;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const CardSelectedExercise({
    super.key,
    required this.index,
    required this.config,
    required this.onEdit,
    required this.onRemove,
    this.onMoveUp,
    this.onMoveDown,
  });

  void _handleAction(_ExerciseAction action) {
    switch (action) {
      case _ExerciseAction.moveUp:
        onMoveUp?.call();
        return;
      case _ExerciseAction.moveDown:
        onMoveDown?.call();
        return;
      case _ExerciseAction.edit:
        onEdit();
        return;
      case _ExerciseAction.remove:
        onRemove();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semanticActions = <CustomSemanticsAction, VoidCallback>{};
    if (onMoveUp != null) {
      semanticActions[const CustomSemanticsAction(
            label: 'Monter dans la liste',
          )] =
          onMoveUp!;
    }
    if (onMoveDown != null) {
      semanticActions[const CustomSemanticsAction(
            label: 'Descendre dans la liste',
          )] =
          onMoveDown!;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: Tooltip(
            message: 'Faire glisser pour réordonner',
            child: Semantics(
              label: 'Réordonner ${config.exercise.name}',
              hint:
                  'Utilisez le glisser-déposer ou les actions Monter et Descendre',
              customSemanticsActions: semanticActions,
              child: const SizedBox.square(
                dimension: 48,
                child: Icon(Icons.drag_handle),
              ),
            ),
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
        trailing: PopupMenuButton<_ExerciseAction>(
          tooltip: 'Actions pour ${config.exercise.name}',
          onSelected: _handleAction,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _ExerciseAction.moveUp,
              enabled: onMoveUp != null,
              child: const ListTile(
                leading: Icon(Icons.arrow_upward),
                title: Text('Monter'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: _ExerciseAction.moveDown,
              enabled: onMoveDown != null,
              child: const ListTile(
                leading: Icon(Icons.arrow_downward),
                title: Text('Descendre'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: _ExerciseAction.edit,
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Modifier'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: _ExerciseAction.remove,
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: colorScheme.error),
                title: const Text('Supprimer'),
                contentPadding: EdgeInsets.zero,
              ),
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
                    child: Semantics(
                      container: true,
                      label: [
                        'Série ${set.setOrder}',
                        if (set.targetReps != null)
                          '${set.targetReps} répétitions',
                        if (set.targetWeight != null)
                          '${set.targetWeight} kilogrammes',
                        if (set.restSeconds != null)
                          '${set.restSeconds} secondes de repos',
                      ].join(', '),
                      child: ExcludeSemantics(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 70,
                              child: Text(
                                'Série ${set.setOrder}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
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
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
