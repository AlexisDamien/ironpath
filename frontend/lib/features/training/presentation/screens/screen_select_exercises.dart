import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/exercise_config.dart';
import '../providers/provider_training.dart';
import '../widgets/card_exercise_list.dart';

class ScreenSelectExercises extends ConsumerStatefulWidget {
  final List<ExerciseConfig> initialSelection;

  const ScreenSelectExercises({super.key, required this.initialSelection});

  @override
  ConsumerState<ScreenSelectExercises> createState() =>
      _ScreenSelectExercisesState();
}

class _ScreenSelectExercisesState extends ConsumerState<ScreenSelectExercises> {
  static const List<String> _muscleGroups = [
    'Quadriceps',
    'Ischio-jambiers',
    'Pectoraux',
    'Dorsaux',
    'Épaules',
    'Biceps',
    'Triceps',
    'Mollets',
    'Abdominaux',
  ];

  final _searchController = TextEditingController();
  late List<ExerciseConfig> _selected;
  String? _selectedMuscleGroup;

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.initialSelection);
    Future.microtask(() => ref.read(providerTraining.notifier).loadExercises());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    ref.read(providerTraining.notifier).loadExercises(
          search:
              _searchController.text.isEmpty ? null : _searchController.text,
          muscleGroup: _selectedMuscleGroup,
        );
  }

  void _toggle(ExerciseConfig config) {
    setState(() {
      if (_selected
          .any((selected) => selected.exercise.id == config.exercise.id)) {
        _selected.removeWhere(
            (selected) => selected.exercise.id == config.exercise.id);
      } else {
        _selected.add(config);
      }
    });
  }

  void _done() {
    Navigator.of(context).pop(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Exercices (${_selected.length})'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _done,
        ),
        actions: [
          TextButton(
            onPressed: _done,
            child: const Text('Valider'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher un exercice...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => _onFilterChanged(),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: const Text('Tous'),
                      selected: _selectedMuscleGroup == null,
                      onSelected: (_) {
                        setState(() => _selectedMuscleGroup = null);
                        _onFilterChanged();
                      },
                    ),
                  ),
                  for (final muscleGroup in _muscleGroups)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(muscleGroup),
                        selected: _selectedMuscleGroup == muscleGroup,
                        onSelected: (_) {
                          setState(() => _selectedMuscleGroup = muscleGroup);
                          _onFilterChanged();
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: CardExerciseList(
                selectedExercises: _selected,
                onToggle: _toggle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
