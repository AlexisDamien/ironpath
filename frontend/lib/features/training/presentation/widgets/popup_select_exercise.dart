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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadExercises());
  }

  Future<void> _loadExercises({String? search}) async {
    if (mounted) setState(() => _isLoading = true);
    await ref.read(providerTraining.notifier).loadExercises(search: search);
    if (mounted) setState(() => _isLoading = false);
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
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Annuler et fermer',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Rechercher un exercice',
                  hintText: 'Nom, muscle ou équipement',
                  prefixIcon: Icon(Icons.search),
                ),
                textInputAction: TextInputAction.search,
                onChanged: (searchValue) => _loadExercises(
                  search: searchValue.isEmpty ? null : searchValue,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Semantics(
                        label: 'Chargement des exercices',
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  : exercises.isEmpty
                  ? const Center(child: Text('Aucun exercice trouvé'))
                  : ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        final details =
                            [exercise.muscleGroup, exercise.equipment]
                                .whereType<String>()
                                .where((value) => value.isNotEmpty);

                        return ListTile(
                          title: Text(exercise.name),
                          subtitle: details.isEmpty
                              ? null
                              : Text(details.join(' • ')),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () => Navigator.of(context).pop(exercise),
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
