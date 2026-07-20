import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/workout_program.dart';
import 'popup_delete_program.dart';

class CardProgram extends ConsumerWidget {
  final WorkoutProgram program;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final bool canWrite;
  final bool isSelected;

  const CardProgram({
    super.key,
    required this.program,
    required this.onSelect,
    required this.onEdit,
    required this.canWrite,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      selected: isSelected,
      button: true,
      label: '${program.name}, ${program.exercises.length} exercices',
      hint: 'Sélectionner ce programme pour démarrer une séance',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 0.5,
          ),
        ),
        child: InkWell(
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            program.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (program.description != null &&
                              program.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              program.description!,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Icon(
                          Icons.check_circle,
                          color: colorScheme.primary,
                          semanticLabel: 'Programme sélectionné',
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      color: colorScheme.primary,
                      onPressed: canWrite ? onEdit : null,
                      tooltip: canWrite
                          ? 'Modifier le programme'
                          : 'Vérifie ton email pour modifier',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: colorScheme.error,
                      onPressed: canWrite
                          ? () => showPopupDeleteProgram(context, ref, program)
                          : null,
                      tooltip: canWrite
                          ? 'Supprimer le programme'
                          : 'Vérifie ton email pour supprimer',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${program.exercises.length} exercice${program.exercises.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      isSelected ? 'Sélectionné' : 'Appuyer pour sélectionner',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
