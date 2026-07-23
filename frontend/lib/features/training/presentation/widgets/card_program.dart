import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/exercise.dart';
import '../../domain/models/workout_program.dart';
import '../providers/provider_training.dart';
import 'popup_delete_program.dart';

class CardProgram extends ConsumerStatefulWidget {
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
  ConsumerState<CardProgram> createState() => _CardProgramState();
}

class _CardProgramState extends ConsumerState<CardProgram> {
  bool _expanded = false;

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);

    if (_expanded && ref.read(providerTraining).exercises.isEmpty) {
      ref.read(providerTraining.notifier).loadExercises();
    }
  }

  String _exerciseLabel(String exerciseId, List<Exercise> catalog) {
    for (final exercise in catalog) {
      if (exercise.id == exerciseId) {
        return exercise.name;
      }
    }
    return 'Exercice';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final catalog = ref.watch(providerTraining).exercises;
    final program = widget.program;

    return Semantics(
      selected: widget.isSelected,
      button: true,
      label: '${program.name}, ${program.exercises.length} exercices',
      hint: 'Sélectionner ce programme pour démarrer une séance',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                widget.isSelected ? colorScheme.primary : colorScheme.outline,
            width: widget.isSelected ? 2 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: widget.onSelect,
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
                        if (widget.isSelected)
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
                          onPressed: widget.canWrite ? widget.onEdit : null,
                          tooltip: widget.canWrite
                              ? 'Modifier le programme'
                              : 'Vérifie ton email pour modifier',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: colorScheme.error,
                          onPressed: widget.canWrite
                              ? () => showPopupDeleteProgram(
                                    context,
                                    ref,
                                    program,
                                  )
                              : null,
                          tooltip: widget.canWrite
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
                          widget.isSelected
                              ? 'Sélectionné'
                              : 'Appuyer pour sélectionner',
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
            InkWell(
              onTap: _toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _expanded
                          ? 'Masquer le détail'
                          : 'Voir le détail des exercices',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final exercise in program.exercises)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _exerciseLabel(exercise.exerciseId, catalog),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            if (exercise.sets.any((set) => set.isWarmup)) ...[
                              Tooltip(
                                message: 'Contient une série d\'échauffement',
                                child: Icon(
                                  Icons.local_fire_department,
                                  size: 14,
                                  color: colorScheme.tertiary,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              '${exercise.sets.length} série${exercise.sets.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
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
      ),
    );
  }
}
