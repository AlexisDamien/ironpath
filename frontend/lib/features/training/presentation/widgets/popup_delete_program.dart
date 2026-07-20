import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/component_modal_header.dart';
import '../../domain/models/workout_program.dart';
import '../providers/provider_training.dart';

void showPopupDeleteProgram(
  BuildContext context,
  WidgetRef ref,
  WorkoutProgram program,
) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 12, 8, 0),
      title: const ComponentModalHeader(title: 'Supprimer le programme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Supprimer « ${program.name} » ? Cette action est irréversible.',
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(providerTraining.notifier).deleteProgram(program.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Supprimer'),
          ),
        ],
      ),
    ),
  );
}
