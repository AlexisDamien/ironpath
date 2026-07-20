import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/format_exception.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_config.dart';
import '../../domain/models/exercise_set_config.dart';
import '../../domain/models/workout_program.dart';
import '../providers/provider_training.dart';
import 'screen_select_exercises.dart';
import '../widgets/form_program.dart';
import '../widgets/card_selected_exercise.dart';
import '../widgets/popup_exercise_config.dart';

class ScreenEditProgram extends ConsumerStatefulWidget {
  final WorkoutProgram? program;

  const ScreenEditProgram({super.key, this.program});

  @override
  ConsumerState<ScreenEditProgram> createState() => _ScreenEditProgramState();
}

class _ScreenEditProgramState extends ConsumerState<ScreenEditProgram> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
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
            _selectedExercises.add(
              ExerciseConfig(
                exercise: exercise,
                sameConfigForAllSets: programExercise.sameConfigForAllSets,
                sets: programExercise.sets
                    .map(
                      (s) => ExerciseSetConfig(
                        setOrder: s.setOrder,
                        targetReps: s.targetReps,
                        targetWeight: s.targetWeight,
                        restSeconds: s.restSeconds,
                      ),
                    )
                    .toList(),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExercises.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      if (widget.program != null) {
        await ref
            .read(providerTraining.notifier)
            .updateProgram(
              programId: widget.program!.id,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              exercises: _selectedExercises,
            );
      } else {
        await ref
            .read(providerTraining.notifier)
            .createProgram(
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
            content: Text(
              formatExceptionMessage(exception),
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openExerciseSelection() async {
    final result = await Navigator.of(context).push<List<ExerciseConfig>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) =>
            ScreenSelectExercises(initialSelection: _selectedExercises),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedExercises
          ..clear()
          ..addAll(result);
      });
    }
  }

  Future<void> _editExercise(ExerciseConfig config) async {
    final updated = await showDialog<ExerciseConfig>(
      context: context,
      builder: (context) => PopupExerciseConfig(
        exercise: config.exercise,
        existingConfig: config,
      ),
    );
    if (updated != null) {
      setState(() {
        final index = _selectedExercises.indexWhere(
          (selected) => selected.exercise.id == config.exercise.id,
        );
        if (index != -1) {
          _selectedExercises[index] = updated;
        }
      });
    }
  }

  void _removeExercise(ExerciseConfig config) {
    setState(() {
      _selectedExercises.removeWhere(
        (selected) => selected.exercise.id == config.exercise.id,
      );
    });
  }

  void _moveExercise(int index, int offset) {
    final newIndex = index + offset;
    if (newIndex < 0 || newIndex >= _selectedExercises.length) return;

    setState(() {
      final item = _selectedExercises.removeAt(index);
      _selectedExercises.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = !_isLoading && _selectedExercises.isNotEmpty;

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
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Annuler et fermer',
            onPressed: () => Navigator.of(context).pop(),
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
            Wrap(
              spacing: 12,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Exercices *',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _openExerciseSelection,
                  icon: const Icon(Icons.add),
                  label: Text(
                    _selectedExercises.isEmpty
                        ? 'Ajouter des exercices'
                        : 'Gérer les exercices',
                  ),
                ),
              ],
            ),
            if (_selectedExercises.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Semantics(
                  liveRegion: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Ajoutez au moins un exercice.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: _selectedExercises.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun exercice sélectionné',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      itemCount: _selectedExercises.length,
                      onReorderItem: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = _selectedExercises.removeAt(oldIndex);
                          _selectedExercises.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final config = _selectedExercises[index];
                        return CardSelectedExercise(
                          key: ValueKey(config.exercise.id),
                          index: index,
                          config: config,
                          onEdit: () => _editExercise(config),
                          onRemove: () => _removeExercise(config),
                          onMoveUp: index > 0
                              ? () => _moveExercise(index, -1)
                              : null,
                          onMoveDown: index < _selectedExercises.length - 1
                              ? () => _moveExercise(index, 1)
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            onPressed: canSubmit ? _submit : null,
            icon: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              _isLoading
                  ? 'Enregistrement…'
                  : widget.program != null
                  ? 'Enregistrer les modifications'
                  : 'Créer le programme',
            ),
          ),
        ),
      ),
    );
  }
}
