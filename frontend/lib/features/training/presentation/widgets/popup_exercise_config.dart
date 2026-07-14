import 'package:flutter/material.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_config.dart';

class PopupExerciseConfig extends StatefulWidget {
  final Exercise exercise;

  const PopupExerciseConfig({super.key, required this.exercise});

  @override
  State<PopupExerciseConfig> createState() => _ExerciseConfigDialogState();
}

class _ExerciseConfigDialogState extends State<PopupExerciseConfig> {
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '10');
  final _weightController = TextEditingController();
  final _restController = TextEditingController(text: '90');

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exercise.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${widget.exercise.muscleGroup ?? ''} • ${widget.exercise.equipment ?? ''}',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _setsController,
                  decoration: const InputDecoration(
                    labelText: 'Séries',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _repsController,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Poids (optionnel)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _restController,
                  decoration: const InputDecoration(
                    labelText: 'Repos (s)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            final config = ExerciseConfig(
              exercise: widget.exercise,
              targetSets: int.tryParse(_setsController.text) ?? 3,
              targetReps: int.tryParse(_repsController.text) ?? 10,
              targetWeight: double.tryParse(_weightController.text),
              restSeconds: int.tryParse(_restController.text) ?? 90,
            );
            Navigator.of(context).pop(config);
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
