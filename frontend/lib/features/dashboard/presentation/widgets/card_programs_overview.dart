import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../training/domain/models/workout_program.dart';

class CardProgramsOverview extends StatelessWidget {
  final List<WorkoutProgram> programs;

  const CardProgramsOverview({super.key, required this.programs});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mes programmes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: () => context.go('/programs'),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (programs.isEmpty)
              Text(
                'Aucun programme créé',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...programs.take(3).map(
                    (program) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(program.name),
                      subtitle: Text(
                        '${program.exercises.length} exercice${program.exercises.length > 1 ? 's' : ''}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.go('/programs'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
