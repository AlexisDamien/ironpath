import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/workout_program.dart';
import '../../domain/training_state.dart';
import '../providers/training_provider.dart';
import '../screens/exercise_detail_screen.dart';

class CreateProgramModal extends ConsumerStatefulWidget {
  final WorkoutProgram? program;

  const CreateProgramModal({super.key, this.program});

  @override
  ConsumerState<CreateProgramModal> createState() => _CreateProgramModalState();
}

class _CreateProgramModalState extends ConsumerState<CreateProgramModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  final List<Exercise> _selectedExercises = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.program != null) {
      _nameController.text = widget.program!.name;
      _descriptionController.text = widget.program!.description ?? '';
    }
    Future.microtask(() async {
      await ref.read(trainingProvider.notifier).loadExercises();
      if (widget.program != null && mounted) {
        final exercises = ref.read(trainingProvider).exercises;
        final programExerciseIds = widget.program!.exercises
            .map((programExercise) => programExercise.exerciseId)
            .toSet();
        setState(() {
          _selectedExercises.addAll(
            exercises.where(
                  (exercise) => programExerciseIds.contains(exercise.id),
            ),
          );
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
        await ref.read(trainingProvider.notifier).updateProgram(
          programId: widget.program!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          exercises: _selectedExercises,
        );
      } else {
        await ref.read(trainingProvider.notifier).createProgram(
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

  void _toggleExercise(Exercise exercise) {
    setState(() {
      if (_selectedExercises.any((selected) => selected.id == exercise.id)) {
        _selectedExercises.removeWhere((selected) => selected.id == exercise.id);
      } else {
        _selectedExercises.add(exercise);
      }
    });
  }

  bool _isSelected(Exercise exercise) {
    return _selectedExercises.any((selected) => selected.id == exercise.id);
  }

  @override
  Widget build(BuildContext context) {
    final trainingState = ref.watch(trainingProvider);
    final exercises = trainingState.exercises;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          widget.program != null ? 'Modifier le programme' : 'Nouveau programme',
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
              'Créer (${_selectedExercises.length})',
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
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du programme',
                      hintText: 'Ex: PPL, Full Body, Push...',
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le nom est requis';
                      }
                      if (value.trim().length < 2) {
                        return 'Le nom doit contenir au moins 2 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optionnel)',
                      hintText: 'Ex: Programme push pull legs 6 jours...',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
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
                  .read(trainingProvider.notifier)
                  .loadExercises(search: searchValue.isEmpty ? null : searchValue),
            ),
            const SizedBox(height: 8),
            if (_selectedExercises.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _selectedExercises
                    .map(
                      (exercise) => Chip(
                    label: Text(exercise.name),
                    onDeleted: () => _toggleExercise(exercise),
                    backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                  ),
                )
                    .toList(),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: trainingState.status == TrainingStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : exercises.isEmpty
                  ? const Center(
                child: Text('Aucun exercice trouvé'),
              )
                  : ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  final isSelected = _isSelected(exercise);
                  return ListTile(
                    title: Text(exercise.name),
                    subtitle: Text(
                      '${exercise.muscleGroup ?? ''} • ${exercise.equipment ?? ''}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => ExerciseDetailScreen(exercise: exercise),
                            ),
                          ),
                        ),
                        isSelected
                            ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                            : const Icon(Icons.add_circle_outline),
                      ],
                    ),
                    onTap: () => _toggleExercise(exercise),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}