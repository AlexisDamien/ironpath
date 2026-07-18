import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/exercise.dart';
import '../providers/provider_rest_timer.dart';
import '../providers/provider_training.dart';
import '../../../identity/presentation/providers/provider_identity.dart';
import '../../domain/models/training_session.dart';
import '../../domain/models/workout_program.dart';
import '../widgets/card_active_session_exercise.dart';
import '../widgets/sheet_add_set.dart';
import 'screen_session_history.dart';

class ScreenSessions extends ConsumerStatefulWidget {
  const ScreenSessions({super.key});

  @override
  ConsumerState<ScreenSessions> createState() => _ScreenSessionsState();
}

class _ScreenSessionsState extends ConsumerState<ScreenSessions>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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

  Future<void> _endSession(TrainingSession activeSession) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer la session'),
        content: const Text('Es-tu sûr de vouloir terminer cette session ?'),
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

    if (activeSession == null) {
      return _buildPlaceholder(canWrite, trainingState.programs);
    }

    WorkoutProgram? linkedProgram;
    if (activeSession.programId != null) {
      for (final program in trainingState.programs) {
        if (program.id == activeSession.programId) {
          linkedProgram = program;
          break;
        }
      }
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
                  activeSession.name ?? 'Session en cours',
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
          child: linkedProgram != null
              ? _buildProgramMirror(linkedProgram, activeSession, trainingState)
              : _buildFreeSession(activeSession),
        ),
      ],
    );
  }

  Widget _buildProgramMirror(
    WorkoutProgram program,
    TrainingSession activeSession,
    dynamic trainingState,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: program.exercises.length,
      itemBuilder: (context, index) {
        final programExercise = program.exercises[index];
        Exercise? exercise;
        for (final candidate in trainingState.exercises) {
          if (candidate.id == programExercise.exerciseId) {
            exercise = candidate;
            break;
          }
        }
        final loggedSets = activeSession.sets
            .where((set) => set.exerciseId == programExercise.exerciseId)
            .toList();

        return CardActiveSessionExercise(
          exerciseName: exercise?.name ?? programExercise.exerciseId,
          muscleGroup: exercise?.muscleGroup,
          programExercise: programExercise,
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
                  exerciseId: programExercise.exerciseId,
                  setOrder: setOrder,
                  reps: reps,
                  weightKg: weightKg,
                  restSeconds: restSeconds,
                  isWarmup: isWarmup,
                );
          },
        );
      },
    );
  }

  Widget _buildFreeSession(TrainingSession activeSession) {
    return Column(
      children: [
        Expanded(
          child: activeSession.sets.isEmpty
              ? Center(
                  child: Text(
                    'Aucun set enregistré — ajoute ton premier exercice',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeSession.sets.length,
                  itemBuilder: (context, index) {
                    final exerciseSet = activeSession.sets[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${exerciseSet.setOrder}'),
                        ),
                        title: Text(exerciseSet.exerciseId),
                        subtitle: Text(
                          '${exerciseSet.reps ?? '-'} reps • ${exerciseSet.weightKg ?? '-'} kg • ${exerciseSet.restSeconds ?? '-'}s repos',
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SheetAddSet(activeSession: activeSession),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un set'),
            ),
          ),
        ),
      ],
    );
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
            const Text('Aucune session en cours',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Démarre une session libre ou depuis un programme',
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
                label: const Text('Session libre'),
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
          content: Text('Vérifie ton email pour démarrer une session')),
    );
  }
}
