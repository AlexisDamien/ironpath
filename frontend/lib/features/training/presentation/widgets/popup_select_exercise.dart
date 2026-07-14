import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_training.dart';

class PopupSelectExercise extends ConsumerStatefulWidget {
  const PopupSelectExercise({super.key});

  @override
  ConsumerState<PopupSelectExercise> createState() =>
      _PopupSelectExerciseState();
}

class _PopupSelectExerciseState extends ConsumerState<PopupSelectExercise> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(providerTraining.notifier).loadExercises());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(providerTraining).exercises;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Choisir un exercice',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
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
          ),
          Expanded(
            child: exercises.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return ListTile(
                        title: Text(exercise.name),
                        subtitle: Text(
                          '${exercise.muscleGroup ?? ''} • ${exercise.equipment ?? ''}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => Navigator.of(context).pop(exercise),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
