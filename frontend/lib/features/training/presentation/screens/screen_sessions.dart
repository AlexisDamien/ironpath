import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_training.dart';
import '../providers/provider_rest_timer.dart';
import '../../../identity/presentation/providers/provider_identity.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_config.dart';
import '../../domain/models/set_target.dart';
import '../../domain/models/training_session.dart';
import '../../domain/models/workout_program.dart';
import '../widgets/card_active_session_exercise.dart';
import 'screen_select_exercises.dart';
import 'screen_session_history.dart';

class ScreenSessions extends ConsumerStatefulWidget {
  const ScreenSessions({super.key});

  @override
  ConsumerState<ScreenSessions> createState() => _ScreenSessionsState();
}

class _ScreenSessionsState extends ConsumerState<ScreenSessions>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<ExerciseConfig> _freeExerciseConfigs = [];
  String? _freeExercisesSessionId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(providerTraining.notifier).loadActiveSession();
      ref.read(providerTraining.notifier).loadPrograms();
      ref.read(providerTraining.notifier).loadExercises();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _syncFreeExercisesWithSession(String? sessionId) {
    if (sessionId != _freeExercisesSessionId) {
      _freeExerciseConfigs.clear();
      _freeExercisesSessionId = sessionId;
    }
  }

  Future<void> _endSession(TrainingSession activeSession) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer la séance'),
        content: const Text('Es-tu sûr de vouloir terminer cette séance ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(providerRestTimer.notifier).clear();
      setState(() => _freeExerciseConfigs.clear());
      await ref.read(providerTraining.notifier).endSession(activeSession.id);
    }
  }

  Future<void> _pickProgramAndStart(List<WorkoutProgram> programs) async {
    if (programs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Aucun programme — crée-en un depuis l'onglet Programmes")),
      );
      return;
    }
    final selected = await showModalBottomSheet<WorkoutProgram>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: programs.map((program) {
            return ListTile(
              title: Text(program.name),
              subtitle: Text('${program.exercises.length} exercices'),
              onTap: () => Navigator.of(context).pop(program),
            );
          }).toList(),
        ),
      ),
    );
    if (selected != null) {
      await ref.read(providerTraining.notifier).startSession(
            programId: selected.id,
            name: selected.name,
          );
    }
  }

  Future<void> _addFreeExercises() async {
    final result = await Navigator.of(context).push<List<ExerciseConfig>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const ScreenSelectExercises(initialSelection: []),
      ),
    );
    if (result == null || result.isEmpty) return;

    setState(() {
      for (final config in result) {
        final alreadyExists = _freeExerciseConfigs
            .any((existing) => existing.exercise.id == config.exercise.id);
        if (!alreadyExists) {
          _freeExerciseConfigs.add(config);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Séances'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Session active'),
                  if (ref.watch(providerTraining).activeSession != null) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.local_fire_department,
                        size: 16, color: Colors.orange),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Historique'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveTab(),
          const ScreenSessionHistory(),
        ],
      ),
    );
  }

  Widget _buildActiveTab() {
    final trainingState = ref.watch(providerTraining);
    final activeSession = trainingState.activeSession;
    final canWrite = ref.watch(providerIdentity).isEmailVerified;

    _syncFreeExercisesWithSession(activeSession?.id);

    if (activeSession == null) {
      return _buildPlaceholder(canWrite, trainingState.programs);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  activeSession.name ?? 'Séance en cours',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              TextButton.icon(
                onPressed: () => _endSession(activeSession),
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Terminer'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildSessionContent(activeSession, trainingState),
        ),
      ],
    );
  }

  Widget _buildSessionContent(
      TrainingSession activeSession, dynamic trainingState) {
    final plannedExerciseIds =
        activeSession.plannedExercises.map((e) => e.exerciseId).toSet();
    final freeConfiguredIds =
        _freeExerciseConfigs.map((c) => c.exercise.id).toSet();

    final orphanFreeSets = activeSession.sets
        .where((set) =>
            !plannedExerciseIds.contains(set.exerciseId) &&
            !freeConfiguredIds.contains(set.exerciseId))
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final plannedExercise in activeSession.plannedExercises)
          _buildPlannedExerciseCard(
              plannedExercise, activeSession, trainingState),
        if (_freeExerciseConfigs.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Exercices libres',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (final config in _freeExerciseConfigs)
            _buildFreeExerciseCard(config, activeSession),
        ],
        if (orphanFreeSets.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Autres sets enregistrés',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (final exerciseSet in orphanFreeSets)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text('${exerciseSet.setOrder}')),
                title: Text(_exerciseName(
                    exerciseSet.exerciseId, trainingState.exercises)),
                subtitle: Text(
                  '${exerciseSet.reps ?? '-'} reps • ${exerciseSet.weightKg ?? '-'} kg • ${exerciseSet.restSeconds ?? '-'}s repos',
                ),
              ),
            ),
        ],
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addFreeExercises,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un exercice libre'),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPlannedExerciseCard(
    SessionPlannedExercise plannedExercise,
    TrainingSession activeSession,
    dynamic trainingState,
  ) {
    final exercise =
        _findExercise(plannedExercise.exerciseId, trainingState.exercises);
    final loggedSets = activeSession.sets
        .where((set) => set.exerciseId == plannedExercise.exerciseId)
        .toList();

    return CardActiveSessionExercise(
      exerciseKey: plannedExercise.id,
      exerciseName: exercise?.name ?? plannedExercise.exerciseId,
      muscleGroup: exercise?.muscleGroup,
      plannedSets: plannedExercise.sets
          .map((s) => SetTarget(
                setOrder: s.setOrder,
                targetReps: s.targetReps,
                targetWeight: s.targetWeight,
                restSeconds: s.restSeconds,
                isWarmup: s.isWarmup,
              ))
          .toList(),
      loggedSets: loggedSets,
      onLogSet: ({
        required setOrder,
        required reps,
        required weightKg,
        required restSeconds,
        required isWarmup,
      }) {
        ref.read(providerTraining.notifier).addSet(
              sessionId: activeSession.id,
              exerciseId: plannedExercise.exerciseId,
              setOrder: setOrder,
              reps: reps,
              weightKg: weightKg,
              restSeconds: restSeconds,
              isWarmup: isWarmup,
            );
      },
    );
  }

  Widget _buildFreeExerciseCard(
      ExerciseConfig config, TrainingSession activeSession) {
    final loggedSets = activeSession.sets
        .where((set) => set.exerciseId == config.exercise.id)
        .toList();

    return CardActiveSessionExercise(
      exerciseKey: 'free-${config.exercise.id}',
      exerciseName: config.exercise.name,
      muscleGroup: config.exercise.muscleGroup,
      plannedSets: config.sets
          .map((s) => SetTarget(
                setOrder: s.setOrder,
                targetReps: s.targetReps,
                targetWeight: s.targetWeight,
                restSeconds: s.restSeconds,
                isWarmup: s.isWarmup,
              ))
          .toList(),
      loggedSets: loggedSets,
      onLogSet: ({
        required setOrder,
        required reps,
        required weightKg,
        required restSeconds,
        required isWarmup,
      }) {
        ref.read(providerTraining.notifier).addSet(
              sessionId: activeSession.id,
              exerciseId: config.exercise.id,
              setOrder: setOrder,
              reps: reps,
              weightKg: weightKg,
              restSeconds: restSeconds,
              isWarmup: isWarmup,
            );
      },
    );
  }

  Exercise? _findExercise(String exerciseId, List exercises) {
    for (final candidate in exercises) {
      if (candidate.id == exerciseId) return candidate as Exercise;
    }
    return null;
  }

  String _exerciseName(String exerciseId, List exercises) {
    for (final exercise in exercises) {
      if (exercise.id == exerciseId) return exercise.name as String;
    }
    return exerciseId;
  }

  Widget _buildPlaceholder(bool canWrite, List<WorkoutProgram> programs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center,
                size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text('Aucune séance en cours',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Démarre une séance libre ou depuis un programme',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canWrite
                    ? () => ref
                        .read(providerTraining.notifier)
                        .startSession(name: 'Session libre')
                    : () => _showVerifyEmailSnack(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Séance libre'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: canWrite
                    ? () => _pickProgramAndStart(programs)
                    : () => _showVerifyEmailSnack(),
                icon: const Icon(Icons.list_alt),
                label: const Text('Depuis un programme'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerifyEmailSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Vérifie ton email pour démarrer une séance')),
    );
  }
}
