import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/training_session.dart';
import '../providers/provider_training.dart';

class SheetAddSet extends ConsumerStatefulWidget {
  final TrainingSession activeSession;

  const SheetAddSet({super.key, required this.activeSession});

  @override
  ConsumerState<SheetAddSet> createState() => _SheetAddSetState();
}

class _SheetAddSetState extends ConsumerState<SheetAddSet> {
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

  Future<void> _addSet() async {
    if (_exerciseIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('L\'identifiant de l\'exercice est requis')),
      );
      return;
    }

    await ref.read(providerTraining.notifier).addSet(
          sessionId: widget.activeSession.id,
          exerciseId: _exerciseIdController.text.trim(),
          setOrder: widget.activeSession.sets.length + 1,
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

  @override
  Widget build(BuildContext context) {
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
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
                  onPressed: _addSet,
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
