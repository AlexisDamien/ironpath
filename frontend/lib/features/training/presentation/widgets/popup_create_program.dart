import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_config.dart';
import '../../domain/models/workout_program.dart';
import '../providers/provider_training.dart';
import 'form_program.dart';
import 'card_exercise_list.dart';

class PopupCreateProgram extends ConsumerStatefulWidget {
  final WorkoutProgram? program;

  const PopupCreateProgram({super.key, this.program});

  @override
  ConsumerState<PopupCreateProgram> createState() => _PopupCreateProgramState();
}

class _PopupCreateProgramState extends ConsumerState<PopupCreateProgram> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  final List<ExerciseConfig> _selectedExercises = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.program != null) {
      _nameController.text = widget.program!.name;
      _descriptionController.text = widget.program!.description ?? '';
    }
    Future.microtask(() async {
      await ref.read(providerTraining.notifier).loadExercises();
      if (widget.program != null && mounted) {
        final exercises = ref.read(providerTraining).exercises;
        setState(() {
          for (final programExercise in widget.program!.exercises) {
            final exercise = exercises.firstWhere(
              (ex) => ex.id == programExercise.exerciseId,
              orElse: () => Exercise(
                id: programExercise.exerciseId,
                name: programExercise.exerciseId,
              ),
            );
            _selectedExercises.add(ExerciseConfig(
              exercise: exercise,
              targetSets: programExercise.targetSets ?? 3,
              targetReps: programExercise.targetReps ?? 10,
              targetWeight: programExercise.targetWeight,
              restSeconds: programExercise.restSeconds ?? 90,
            ));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (widget.program != null) {
        await ref.read(providerTraining.notifier).updateProgram(
              programId: widget.program!.id,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              exercises: _selectedExercises,
            );
      } else {
        await ref.read(providerTraining.notifier).createProgram(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              exercises: _selectedExercises,
            );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (exception) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exception.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleExercise(ExerciseConfig config) {
    setState(() {
      if (_selectedExercises
          .any((selected) => selected.exercise.id == config.exercise.id)) {
        _selectedExercises.removeWhere(
            (selected) => selected.exercise.id == config.exercise.id);
      } else {
        _selectedExercises.add(config);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          widget.program != null
              ? 'Modifier le programme'
              : 'Nouveau programme',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    widget.program != null
                        ? 'Modifier (${_selectedExercises.length})'
                        : 'Créer (${_selectedExercises.length})',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: FormProgram(
                nameController: _nameController,
                descriptionController: _descriptionController,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Exercices',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher un exercice...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (searchValue) => ref
                  .read(providerTraining.notifier)
                  .loadExercises(
                      search: searchValue.isEmpty ? null : searchValue),
            ),
            const SizedBox(height: 8),
            if (_selectedExercises.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _selectedExercises
                    .map(
                      (config) => Chip(
                        label: Text(
                          '${config.exercise.name} • ${config.targetSets}x${config.targetReps}',
                        ),
                        onDeleted: () =>
                            setState(() => _selectedExercises.remove(config)),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: CardExerciseList(
                selectedExercises: _selectedExercises,
                onToggle: _toggleExercise,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
