import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/parse_input.dart';
import '../../../../core/widgets/component_modal_header.dart';
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
  final _formKey = GlobalKey<FormState>();
  Exercise? _selectedExercise;
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _restController = TextEditingController();
  bool _isWarmup = false;
  bool _showExerciseError = false;
  bool _isSaving = false;

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
      setState(() {
        _selectedExercise = exercise;
        _showExerciseError = false;
      });
    }
  }

  String? _validatePositiveInteger(String? value, String fieldName) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 0) {
      return '$fieldName doit être un nombre entier positif';
    }
    return null;
  }

  String? _validatePositiveDecimal(String? value, String fieldName) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = parseDecimal(text);
    if (parsed == null || parsed < 0) {
      return '$fieldName doit être un nombre positif';
    }
    return null;
  }

  Future<void> _addSet() async {
    if (_isSaving) return;

    final hasExercise = _selectedExercise != null;
    setState(() => _showExerciseError = !hasExercise);
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!hasExercise || !formValid) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    try {
      await ref.read(providerTraining.notifier).addSet(
            sessionId: widget.activeSession.id,
            exerciseId: _selectedExercise!.id,
            setOrder: widget.activeSession.sets.length + 1,
            reps: _repsController.text.trim().isEmpty
                ? null
                : int.parse(_repsController.text.trim()),
            weightKg: parseDecimal(_weightController.text),
            restSeconds: _restController.text.trim().isEmpty
                ? null
                : int.parse(_restController.text.trim()),
            isWarmup: _isWarmup,
          );

      if (!mounted) return;
      setState(() {
        _selectedExercise = null;
        _isWarmup = false;
        _showExerciseError = false;
      });
      _repsController.clear();
      _weightController.clear();
      _restController.clear();
      _formKey.currentState?.reset();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ComponentModalHeader(title: 'Ajouter une série'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickExercise,
                icon: const Icon(Icons.fitness_center),
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_selectedExercise?.name ?? 'Choisir un exercice'),
                ),
              ),
              if (_showExerciseError) ...[
                const SizedBox(height: 6),
                Semantics(
                  liveRegion: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sélectionnez un exercice.',
                          style: TextStyle(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _repsController,
                decoration: const InputDecoration(
                  labelText: 'Répétitions',
                  hintText: 'Ex. 10',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    _validatePositiveInteger(value, 'Le nombre de répétitions'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Poids (kg)',
                  hintText: 'Ex. 20,5',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    _validatePositiveDecimal(value, 'Le poids'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _restController,
                decoration: const InputDecoration(
                  labelText: 'Temps de repos (secondes)',
                  hintText: 'Ex. 90',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (value) =>
                    _validatePositiveInteger(value, 'Le temps de repos'),
                onFieldSubmitted: (_) => _addSet(),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _isWarmup,
                onChanged: (value) => setState(() => _isWarmup = value),
                title: const Text('Série d’échauffement'),
                subtitle: const Text(
                  'Cette série sera identifiée comme un échauffement.',
                ),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _addSet,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(_isSaving ? 'Ajout en cours' : 'Ajouter la série'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
