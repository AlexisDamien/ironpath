import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/training_session.dart';
import '../providers/provider_training.dart';
import 'popup_select_exercise.dart';

class SheetAddSet extends ConsumerStatefulWidget {
  final TrainingSession activeSession;

  const SheetAddSet({super.key, required this.activeSession});

  @override
  ConsumerState<SheetAddSet> createState() => _SheetAddSetState();
}

class _SheetAddSetState extends ConsumerState<SheetAddSet> {
  Exercise? _selectedExercise;
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _restController = TextEditingController();
  bool _isWarmup = false;

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    super.dispose();
  }

  Future<void> _pickExercise() async {
    final exercise = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const PopupSelectExercise(),
      ),
    );
    if (exercise != null) {
      setState(() => _selectedExercise = exercise);
    }
  }

  Future<void> _addSet() async {
    if (_selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionne un exercice')),
      );
      return;
    }

    await ref.read(providerTraining.notifier).addSet(
          sessionId: widget.activeSession.id,
          exerciseId: _selectedExercise!.id,
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

    setState(() => _selectedExercise = null);
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
          GestureDetector(
            onTap: _pickExercise,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.fitness_center, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedExercise?.name ?? 'Choisir un exercice',
                      style: TextStyle(
                        color: _selectedExercise != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.grey,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
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
