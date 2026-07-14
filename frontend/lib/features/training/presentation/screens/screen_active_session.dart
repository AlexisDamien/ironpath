import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_training.dart';
import '../../domain/models/training_session.dart';
import '../widgets/sheet_add_set.dart';

class ScreenActiveSession extends ConsumerWidget {
  const ScreenActiveSession({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(providerTraining);
    final activeSession = trainingState.activeSession;

    if (activeSession == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Session active'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Aucune session en cours',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Démarre une session depuis tes programmes',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(activeSession.name ?? 'Session en cours'),
        actions: [
          TextButton.icon(
            onPressed: () => _endSession(context, ref, activeSession),
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text('Terminer'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: activeSession.sets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucun set enregistré',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ajoute ton premier set ci-dessous',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activeSession.sets.length,
                    itemBuilder: (context, index) {
                      final exerciseSet = activeSession.sets[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: Text(
                              '${exerciseSet.setOrder}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(exerciseSet.exerciseId),
                          subtitle: Text(
                            '${exerciseSet.reps ?? '-'} reps • ${exerciseSet.weightKg ?? '-'} kg',
                          ),
                          trailing: exerciseSet.isWarmup
                              ? Chip(
                                  label: const Text('Échauffement'),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
          SheetAddSet(activeSession: activeSession),
        ],
      ),
    );
  }

  Future<void> _endSession(BuildContext context, WidgetRef ref,
      TrainingSession activeSession) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer la session'),
        content: const Text('Es-tu sûr de vouloir terminer cette session ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(providerTraining.notifier).endSession(activeSession.id);
    }
  }
}
