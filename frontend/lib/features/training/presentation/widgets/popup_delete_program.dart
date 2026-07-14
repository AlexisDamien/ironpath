import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/workout_program.dart';
import '../providers/provider_training.dart';

void showPopupDeleteProgram(
    BuildContext context, WidgetRef ref, WorkoutProgram program) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer le programme'),
      content: Text(
        'Supprimer "${program.name}" ? Cette action est irréversible.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            ref.read(providerTraining.notifier).deleteProgram(program.id);
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
}
