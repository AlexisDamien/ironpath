import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_config.dart';
import '../providers/provider_training.dart';
import '../screens/screen_exercise_detail.dart';
import 'popup_exercise_config.dart';

class CardExerciseList extends ConsumerWidget {
  final List<ExerciseConfig> selectedExercises;
  final Function(ExerciseConfig) onToggle;

  const CardExerciseList({
    super.key,
    required this.selectedExercises,
    required this.onToggle,
  });

  ExerciseConfig? _configFor(Exercise exercise) {
    for (final config in selectedExercises) {
      if (config.exercise.id == exercise.id) return config;
    }
    return null;
  }

  bool _hasWarmupSet(ExerciseConfig? config) {
    if (config == null) return false;
    return config.sets.any((set) => set.isWarmup);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(providerTraining).exercises;

    if (exercises.isEmpty) {
      return const Center(child: Text('Aucun exercice trouvé'));
    }

    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final config = _configFor(exercise);
        final isSelected = config != null;
        final hasWarmup = _hasWarmupSet(config);

        return ListTile(
          title: Text(exercise.name),
          subtitle: Text(
            '${exercise.muscleGroup ?? ''} • ${exercise.equipment ?? ''}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasWarmup) ...[
                const Icon(Icons.local_fire_department,
                    size: 18, color: Colors.orange),
                const SizedBox(width: 4),
              ],
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () async {
                  final result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => ScreenExerciseDetail(
                        exercise: exercise,
                        showAddButton: true,
                        isSelected: isSelected,
                      ),
                    ),
                  );
                  if (!context.mounted) return;
                  if (result == 'add_to_program') {
                    final newConfig = await showDialog<ExerciseConfig>(
                      context: context,
                      builder: (context) =>
                          PopupExerciseConfig(exercise: exercise),
                    );
                    if (newConfig != null) onToggle(newConfig);
                  } else if (result == 'remove_from_program' && isSelected) {
                    onToggle(config);
                  }
                },
              ),
              isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : const Icon(Icons.add_circle_outline),
            ],
          ),
          onTap: () async {
            if (isSelected) {
              onToggle(config);
            } else {
              final newConfig = await showDialog<ExerciseConfig>(
                context: context,
                builder: (context) => PopupExerciseConfig(exercise: exercise),
              );
              if (newConfig != null) {
                onToggle(newConfig);
              }
            }
          },
        );
      },
    );
  }
}
