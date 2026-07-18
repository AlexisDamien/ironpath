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

  bool _isSelected(Exercise exercise) {
    return selectedExercises.any((config) => config.exercise.id == exercise.id);
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
        final isSelected = _isSelected(exercise);
        return ListTile(
          title: Text(exercise.name),
          subtitle: Text(
            '${exercise.muscleGroup ?? ''} • ${exercise.equipment ?? ''}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    final config = await showDialog<ExerciseConfig>(
                      context: context,
                      builder: (context) =>
                          PopupExerciseConfig(exercise: exercise),
                    );
                    if (config != null) onToggle(config);
                  } else if (result == 'remove_from_program' && isSelected) {
                    onToggle(
                      selectedExercises.firstWhere(
                        (config) => config.exercise.id == exercise.id,
                      ),
                    );
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
              onToggle(
                selectedExercises.firstWhere(
                  (config) => config.exercise.id == exercise.id,
                ),
              );
            } else {
              final config = await showDialog<ExerciseConfig>(
                context: context,
                builder: (context) => PopupExerciseConfig(exercise: exercise),
              );
              if (config != null) {
                onToggle(config);
              }
            }
          },
        );
      },
    );
  }
}
