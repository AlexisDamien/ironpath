import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../identity/presentation/providers/provider_identity.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_config.dart';
import '../../domain/models/set_target.dart';
import '../../domain/models/training_session.dart';
import '../../domain/models/workout_program.dart';
import '../../domain/state_training.dart';
import '../providers/provider_rest_timer.dart';
import '../providers/provider_training.dart';
import '../widgets/card_active_session_exercise.dart';
import '../widgets/card_logged_set.dart';
import '../widgets/card_session_start.dart';
import '../widgets/popup_end_session.dart';
import '../widgets/sheet_select_program.dart';
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
    if (sessionId == _freeExercisesSessionId) {
      return;
    }

    _freeExerciseConfigs.clear();
    _freeExercisesSessionId = sessionId;
  }

  Future<void> _endSession(TrainingSession activeSession) async {
    final confirmed = await showEndSessionDialog(context);
    if (!confirmed) {
      return;
    }

    ref.read(providerRestTimer.notifier).clear();
    setState(_freeExerciseConfigs.clear);
    await ref.read(providerTraining.notifier).endSession(activeSession.id);
  }

  Future<void> _pickProgramAndStart(List<WorkoutProgram> programs) async {
    if (programs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Aucun programme — crée-en un depuis l'onglet Programmes",
          ),
        ),
      );
      return;
    }

    final selected = await showSelectProgramSheet(context, programs: programs);

    if (selected == null) {
      return;
    }

    await ref
        .read(providerTraining.notifier)
        .startSession(programId: selected.id, name: selected.name);
  }

  Future<void> _addFreeExercises() async {
    final result = await Navigator.of(context).push<List<ExerciseConfig>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const ScreenSelectExercises(initialSelection: []),
      ),
    );

    if (result == null || result.isEmpty) {
      return;
    }

    setState(() {
      for (final config in result) {
        final alreadyExists = _freeExerciseConfigs.any(
          (existing) => existing.exercise.id == config.exercise.id,
        );

        if (!alreadyExists) {
          _freeExerciseConfigs.add(config);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final trainingState = ref.watch(providerTraining);

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
                  if (trainingState.activeSession != null) ...[
                    const SizedBox(width: 6),
                    Tooltip(
                      message: 'Une séance est en cours',
                      child: Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
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
          _buildActiveTab(trainingState),
          const ScreenSessionHistory(),
        ],
      ),
    );
  }

  Widget _buildActiveTab(StateTraining trainingState) {
    final activeSession = trainingState.activeSession;
    final canWrite = ref.watch(providerIdentity).isEmailVerified;

    _syncFreeExercisesWithSession(activeSession?.id);

    if (activeSession == null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: CardSessionStart(
                canWrite: canWrite,
                onStartFree: () => ref
                    .read(providerTraining.notifier)
                    .startSession(name: 'Session libre'),
                onStartProgram: () =>
                    _pickProgramAndStart(trainingState.programs),
                onRequiresVerification: _showVerifyEmailSnack,
              ),
            ),
          );
        },
      );
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
        Expanded(child: _buildSessionContent(activeSession, trainingState)),
      ],
    );
  }

  Widget _buildSessionContent(
    TrainingSession activeSession,
    StateTraining trainingState,
  ) {
    final plannedExerciseIds = activeSession.plannedExercises
        .map((exercise) => exercise.exerciseId)
        .toSet();
    final freeConfiguredIds = _freeExerciseConfigs
        .map((config) => config.exercise.id)
        .toSet();
    final orphanFreeSets = activeSession.sets
        .where(
          (set) =>
              !plannedExerciseIds.contains(set.exerciseId) &&
              !freeConfiguredIds.contains(set.exerciseId),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final plannedExercise in activeSession.plannedExercises)
          _buildPlannedExerciseCard(
            plannedExercise,
            activeSession,
            trainingState.exercises,
          ),
        if (_freeExerciseConfigs.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Exercices libres',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          for (final config in _freeExerciseConfigs)
            _buildFreeExerciseCard(config, activeSession),
        ],
        if (orphanFreeSets.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Autres sets enregistrés',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          for (final exerciseSet in orphanFreeSets)
            CardLoggedSet(
              exerciseSet: exerciseSet,
              exerciseName: _exerciseName(
                exerciseSet.exerciseId,
                trainingState.exercises,
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
    List<Exercise> exercises,
  ) {
    final exercise = _findExercise(plannedExercise.exerciseId, exercises);
    final loggedSets = activeSession.sets
        .where((set) => set.exerciseId == plannedExercise.exerciseId)
        .toList();

    return CardActiveSessionExercise(
      exerciseKey: plannedExercise.id,
      exerciseName: exercise?.name ?? plannedExercise.exerciseId,
      muscleGroup: exercise?.muscleGroup,
      plannedSets: plannedExercise.sets
          .map(
            (set) => SetTarget(
              setOrder: set.setOrder,
              targetReps: set.targetReps,
              targetWeight: set.targetWeight,
              restSeconds: set.restSeconds,
              isWarmup: set.isWarmup,
            ),
          )
          .toList(),
      loggedSets: loggedSets,
      onLogSet:
          ({
            required setOrder,
            required reps,
            required weightKg,
            required restSeconds,
            required isWarmup,
          }) {
            ref
                .read(providerTraining.notifier)
                .addSet(
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
    ExerciseConfig config,
    TrainingSession activeSession,
  ) {
    final loggedSets = activeSession.sets
        .where((set) => set.exerciseId == config.exercise.id)
        .toList();

    return CardActiveSessionExercise(
      exerciseKey: 'free-${config.exercise.id}',
      exerciseName: config.exercise.name,
      muscleGroup: config.exercise.muscleGroup,
      plannedSets: config.sets
          .map(
            (set) => SetTarget(
              setOrder: set.setOrder,
              targetReps: set.targetReps,
              targetWeight: set.targetWeight,
              restSeconds: set.restSeconds,
              isWarmup: set.isWarmup,
            ),
          )
          .toList(),
      loggedSets: loggedSets,
      onLogSet:
          ({
            required setOrder,
            required reps,
            required weightKg,
            required restSeconds,
            required isWarmup,
          }) {
            ref
                .read(providerTraining.notifier)
                .addSet(
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

  Exercise? _findExercise(String exerciseId, List<Exercise> exercises) {
    for (final exercise in exercises) {
      if (exercise.id == exerciseId) {
        return exercise;
      }
    }

    return null;
  }

  String _exerciseName(String exerciseId, List<Exercise> exercises) {
    return _findExercise(exerciseId, exercises)?.name ?? exerciseId;
  }

  void _showVerifyEmailSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vérifie ton email pour démarrer une séance'),
      ),
    );
  }
}
