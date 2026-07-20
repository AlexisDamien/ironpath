import 'package:flutter/material.dart';

class CardSessionStart extends StatelessWidget {
  final bool canWrite;
  final VoidCallback onStartFree;
  final VoidCallback onStartProgram;
  final VoidCallback onRequiresVerification;

  const CardSessionStart({
    super.key,
    required this.canWrite,
    required this.onStartFree,
    required this.onStartProgram,
    required this.onRequiresVerification,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucune séance en cours',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Démarre une séance libre ou depuis un programme',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canWrite ? onStartFree : onRequiresVerification,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Séance libre'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: canWrite
                        ? onStartProgram
                        : onRequiresVerification,
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Depuis un programme'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
