import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../identity/presentation/providers/provider_identity.dart';
import '../../domain/models/workout_program.dart';
import '../../domain/state_training.dart';
import '../providers/provider_training.dart';
import '../widgets/card_program.dart';
import 'screen_edit_program.dart';

class ScreenPrograms extends ConsumerStatefulWidget {
  const ScreenPrograms({super.key});

  @override
  ConsumerState<ScreenPrograms> createState() => _ScreenProgramsState();
}

class _ScreenProgramsState extends ConsumerState<ScreenPrograms> {
  String? _selectedProgramId;
  bool _isStarting = false;
  bool _isCheckingActiveSession = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadPageData);
  }

  Future<void> _loadPageData() async {
    if (mounted) {
      setState(() => _isCheckingActiveSession = true);
    }

    await Future.wait([
      ref.read(providerTraining.notifier).loadPrograms(),
      ref.read(providerTraining.notifier).loadActiveSession(),
    ]);

    if (mounted) {
      setState(() => _isCheckingActiveSession = false);
    }
  }

  WorkoutProgram? _selectedProgram(List<WorkoutProgram> programs) {
    for (final program in programs) {
      if (program.id == _selectedProgramId) return program;
    }
    return null;
  }

  Future<void> _startSelectedProgram(WorkoutProgram program) async {
    if (_isStarting ||
        _isCheckingActiveSession ||
        ref.read(providerTraining).activeSession != null) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isStarting = true);
    try {
      await ref
          .read(providerTraining.notifier)
          .startSession(programId: program.id, name: program.name);

      if (!mounted) return;

      final state = ref.read(providerTraining);
      if (state.activeSession != null) {
        context.go('/session');
      } else if (state.errorMessage != null) {
        messenger.showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      }
    } finally {
      if (mounted) {
        setState(() => _isStarting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainingState = ref.watch(providerTraining);
    final canWrite = ref.watch(providerIdentity).isEmailVerified;
    final selectedProgram = _selectedProgram(trainingState.programs);
    final hasActiveSession = trainingState.activeSession != null;
    final hasPrograms = trainingState.programs.isNotEmpty;

    final canStart =
        canWrite &&
        !hasActiveSession &&
        !_isCheckingActiveSession &&
        selectedProgram != null &&
        !_isStarting;

    final String statusMessage;
    if (_isCheckingActiveSession) {
      statusMessage = 'Vérification de la séance active…';
    } else if (hasActiveSession) {
      statusMessage = 'Une séance est déjà en cours.';
    } else if (selectedProgram == null) {
      statusMessage = 'Sélectionnez un programme dans la liste.';
    } else {
      statusMessage = 'Programme sélectionné : ${selectedProgram.name}';
    }

    final String startButtonLabel;
    if (_isCheckingActiveSession) {
      startButtonLabel = 'Vérification…';
    } else if (hasActiveSession) {
      startButtonLabel = 'Séance en cours';
    } else if (_isStarting) {
      startButtonLabel = 'Démarrage…';
    } else {
      startButtonLabel = 'Démarrer';
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Mes programmes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: canWrite ? () => _openCreateProgram(context) : null,
            tooltip: canWrite
                ? 'Créer un programme'
                : 'Vérifie ton email pour créer un programme',
          ),
        ],
      ),
      body: _buildBody(context, trainingState, canWrite),
      bottomNavigationBar: hasPrograms
          ? SafeArea(
              top: false,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        statusMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: canStart
                            ? () => _startSelectedProgram(selectedProgram)
                            : null,
                        icon: _isStarting || _isCheckingActiveSession
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(startButtonLabel),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(
    BuildContext context,
    StateTraining trainingState,
    bool canWrite,
  ) {
    if (trainingState.status == StatusTraining.loading &&
        trainingState.programs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (trainingState.status == StatusTraining.error &&
        trainingState.programs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                trainingState.errorMessage ?? 'Une erreur est survenue',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(providerTraining.notifier).loadPrograms(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (trainingState.programs.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Aucun programme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Crée ton premier programme d’entraînement.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: canWrite ? () => _openCreateProgram(context) : null,
                icon: const Icon(Icons.add),
                label: const Text('Créer un programme'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPageData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        itemCount: trainingState.programs.length,
        itemBuilder: (context, index) {
          final program = trainingState.programs[index];
          return CardProgram(
            program: program,
            canWrite: canWrite,
            isSelected: _selectedProgramId == program.id,
            onSelect: () => setState(() => _selectedProgramId = program.id),
            onEdit: () => Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => ScreenEditProgram(program: program),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openCreateProgram(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const ScreenEditProgram(),
      ),
    );
  }
}
