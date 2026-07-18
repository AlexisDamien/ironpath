import 'package:flutter/material.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_config.dart';
import '../../domain/models/exercise_set_config.dart';

class PopupExerciseConfig extends StatefulWidget {
  final Exercise exercise;
  final ExerciseConfig? existingConfig;

  const PopupExerciseConfig({
    super.key,
    required this.exercise,
    this.existingConfig,
  });

  @override
  State<PopupExerciseConfig> createState() => _PopupExerciseConfigState();
}

class _PopupExerciseConfigState extends State<PopupExerciseConfig> {
  late final TextEditingController _setsCountController;
  bool _sameConfigForAllSets = true;

  late final TextEditingController _globalRepsController;
  late final TextEditingController _globalWeightController;
  late final TextEditingController _globalRestController;

  List<TextEditingController> _repsControllers = [];
  List<TextEditingController> _weightControllers = [];
  List<TextEditingController> _restControllers = [];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingConfig;
    final initialSetsCount = existing?.sets.length ?? 3;
    _sameConfigForAllSets = existing?.sameConfigForAllSets ?? true;

    _setsCountController = TextEditingController(text: '$initialSetsCount');

    final firstSet = (existing != null && existing.sets.isNotEmpty)
        ? existing.sets.first
        : null;
    _globalRepsController =
        TextEditingController(text: '${firstSet?.targetReps ?? 10}');
    _globalWeightController =
        TextEditingController(text: firstSet?.targetWeight?.toString() ?? '');
    _globalRestController =
        TextEditingController(text: '${firstSet?.restSeconds ?? 90}');

    _rebuildPerSetControllers(initialSetsCount, existing?.sets);
  }

  void _rebuildPerSetControllers(
      int count, List<ExerciseSetConfig>? existingSets) {
    _repsControllers = List.generate(count, (index) {
      final value = (existingSets != null && index < existingSets.length)
          ? existingSets[index].targetReps
          : int.tryParse(_globalRepsController.text);
      return TextEditingController(text: value?.toString() ?? '10');
    });
    _weightControllers = List.generate(count, (index) {
      final value = (existingSets != null && index < existingSets.length)
          ? existingSets[index].targetWeight
          : double.tryParse(_globalWeightController.text);
      return TextEditingController(text: value?.toString() ?? '');
    });
    _restControllers = List.generate(count, (index) {
      final value = (existingSets != null && index < existingSets.length)
          ? existingSets[index].restSeconds
          : int.tryParse(_globalRestController.text);
      return TextEditingController(text: value?.toString() ?? '90');
    });
  }

  void _onSetsCountChanged(String value) {
    final count = int.tryParse(value);
    if (count == null || count < 1) return;
    for (final controller in _repsControllers) {
      controller.dispose();
    }
    for (final controller in _weightControllers) {
      controller.dispose();
    }
    for (final controller in _restControllers) {
      controller.dispose();
    }
    setState(() {
      _rebuildPerSetControllers(count, null);
    });
  }

  @override
  void dispose() {
    _setsCountController.dispose();
    _globalRepsController.dispose();
    _globalWeightController.dispose();
    _globalRestController.dispose();
    for (final controller in _repsControllers) {
      controller.dispose();
    }
    for (final controller in _weightControllers) {
      controller.dispose();
    }
    for (final controller in _restControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final setsCount = int.tryParse(_setsCountController.text) ?? 3;
    if (setsCount < 1) return;

    List<ExerciseSetConfig> sets;
    if (_sameConfigForAllSets) {
      final reps = int.tryParse(_globalRepsController.text);
      final weight = double.tryParse(_globalWeightController.text);
      final rest = int.tryParse(_globalRestController.text);
      sets = List.generate(
        setsCount,
        (index) => ExerciseSetConfig(
          setOrder: index + 1,
          targetReps: reps,
          targetWeight: weight,
          restSeconds: rest,
        ),
      );
    } else {
      sets = List.generate(setsCount, (index) {
        return ExerciseSetConfig(
          setOrder: index + 1,
          targetReps: index < _repsControllers.length
              ? int.tryParse(_repsControllers[index].text)
              : null,
          targetWeight: index < _weightControllers.length
              ? double.tryParse(_weightControllers[index].text)
              : null,
          restSeconds: index < _restControllers.length
              ? int.tryParse(_restControllers[index].text)
              : null,
        );
      });
    }

    final config = ExerciseConfig(
      exercise: widget.exercise,
      sameConfigForAllSets: _sameConfigForAllSets,
      sets: sets,
    );
    Navigator.of(context).pop(config);
  }

  @override
  Widget build(BuildContext context) {
    final setsCount = int.tryParse(_setsCountController.text) ?? 3;

    return AlertDialog(
      title: Text(widget.exercise.name),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.exercise.muscleGroup ?? ''} • ${widget.exercise.equipment ?? ''}',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _setsCountController,
                decoration:
                    const InputDecoration(labelText: 'Nombre de séries'),
                keyboardType: TextInputType.number,
                onChanged: _onSetsCountChanged,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Même config pour toutes les séries',
                  style: TextStyle(fontSize: 14),
                ),
                value: _sameConfigForAllSets,
                onChanged: (value) =>
                    setState(() => _sameConfigForAllSets = value),
              ),
              const SizedBox(height: 8),
              if (_sameConfigForAllSets) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _globalRepsController,
                        decoration:
                            const InputDecoration(labelText: 'Répétitions'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _globalWeightController,
                        decoration: const InputDecoration(
                            labelText: 'Poids (kg, optionnel)'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _globalRestController,
                  decoration: const InputDecoration(labelText: 'Repos (s)'),
                  keyboardType: TextInputType.number,
                ),
              ] else
                ...List.generate(setsCount, (index) {
                  if (index >= _repsControllers.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Série ${index + 1}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _repsControllers[index],
                                decoration:
                                    const InputDecoration(labelText: 'Reps'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _weightControllers[index],
                                decoration: const InputDecoration(
                                    labelText: 'Poids (kg)'),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _restControllers[index],
                                decoration: const InputDecoration(
                                    labelText: 'Repos (s)'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
