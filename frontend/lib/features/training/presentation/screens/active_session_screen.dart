import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/training_provider.dart';
import '../../domain/models/training_session.dart';

class ActiveSessionScreen extends ConsumerStatefulWidget {
  const ActiveSessionScreen({super.key});

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  final _exerciseIdController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _restController = TextEditingController();
  bool _isWarmup = false;

  @override
  void dispose() {
    _exerciseIdController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    super.dispose();
  }

  Future<void> _addSet(TrainingSession activeSession) async {
    if (_exerciseIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('L\'identifiant de l\'exercice est requis')),
      );
      return;
    }

    await ref.read(trainingProvider.notifier).addSet(
      sessionId: activeSession.id,
      exerciseId: _exerciseIdController.text.trim(),
      setOrder: activeSession.sets.length + 1,
      reps: _repsController.text.isEmpty
          ? null
          : int.tryParse(_repsController.text),
      weightKg: _weightController.text.isEmpty
          ? null
          : double.tryParse(_weightController.text),
      restSeconds: _restController.text.isEmpty
          ? null
          : int.tryParse(_restController.text),
      isWarmup: _isWarmup,
    );

    _exerciseIdController.clear();
    _repsController.clear();
    _weightController.clear();
    _restController.clear();
    setState(() => _isWarmup = false);
  }

  Future<void> _endSession(TrainingSession activeSession) async {
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
      await ref.read(trainingProvider.notifier).endSession(activeSession.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainingState = ref.watch(trainingProvider);
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
            onPressed: () => _endSession(activeSession),
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
          _buildAddSetPanel(context, activeSession),
        ],
      ),
    );
  }

  Widget _buildAddSetPanel(
      BuildContext context, TrainingSession activeSession) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ajouter un set',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _exerciseIdController,
            decoration: const InputDecoration(
              labelText: 'Exercice',
              hintText: 'ID ou nom de l\'exercice',
              prefixIcon: Icon(Icons.fitness_center),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _repsController,
                  decoration: const InputDecoration(labelText: 'Reps'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: 'Poids'),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _restController,
                  decoration: const InputDecoration(labelText: 'Repos (s)'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Switch(
                value: _isWarmup,
                onChanged: (value) => setState(() => _isWarmup = value),
              ),
              const Text('Échauffement'),
              const Spacer(),
              SizedBox(
                width: 120,
                child: ElevatedButton.icon(
                  onPressed: () => _addSet(activeSession),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}