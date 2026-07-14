import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/provider_training.dart';

class SheetStartSession extends ConsumerWidget {
  const SheetStartSession({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(providerTraining);
    final hasActiveSession = trainingState.activeSession != null;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: hasActiveSession
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: Theme.of(context).colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Une session est déjà en cours',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Termine ta session actuelle avant d\'en démarrer une nouvelle.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/session');
                    },
                    icon: const Icon(Icons.fitness_center),
                    label: const Text('Reprendre la session'),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Démarrer une session',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await ref.read(providerTraining.notifier).startSession(
                            name: 'Session libre',
                          );
                      if (context.mounted) context.push('/session');
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Session libre'),
                  ),
                ),
                const SizedBox(height: 12),
                if (trainingState.programs.isNotEmpty) ...[
                  const Text(
                    'Depuis un programme',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...trainingState.programs.map(
                    (program) => Material(
                      color: Colors.transparent,
                      child: ListTile(
                        title: Text(program.name),
                        subtitle: Text(
                          '${program.exercises.length} exercice${program.exercises.length > 1 ? 's' : ''}',
                        ),
                        trailing: const Icon(Icons.play_arrow),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await ref
                              .read(providerTraining.notifier)
                              .startSession(
                                programId: program.id,
                                name: program.name,
                              );
                          if (context.mounted) context.push('/session');
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
