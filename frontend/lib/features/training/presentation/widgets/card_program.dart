import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/workout_program.dart';
import 'popup_delete_program.dart';

class CardProgram extends ConsumerWidget {
  final WorkoutProgram program;
  final VoidCallback onStartSession;
  final VoidCallback onEdit;
  final bool canWrite;

  const CardProgram({
    super.key,
    required this.program,
    required this.onStartSession,
    required this.onEdit,
    required this.canWrite,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    program.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: canWrite ? onEdit : null,
                  tooltip: canWrite ? null : 'Vérifie ton email pour modifier',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                  onPressed: canWrite
                      ? () => showPopupDeleteProgram(context, ref, program)
                      : null,
                  tooltip: canWrite ? null : 'Vérifie ton email pour supprimer',
                ),
              ],
            ),
            if (program.description != null && program.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  program.description!,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${program.exercises.length} exercice${program.exercises.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Tooltip(
                  message: canWrite ? '' : 'Vérifie ton email pour démarrer',
                  child: SizedBox(
                    width: 130,
                    child: ElevatedButton.icon(
                      onPressed: canWrite ? onStartSession : null,
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Démarrer'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
