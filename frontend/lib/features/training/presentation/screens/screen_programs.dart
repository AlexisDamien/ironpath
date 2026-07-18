import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ironpath/features/training/presentation/screens/screen_sessions.dart';
import '../providers/provider_training.dart';
import '../widgets/card_program.dart';
import 'screen_edit_program.dart';
import '../../domain/state_training.dart';
import '../../../identity/presentation/providers/provider_identity.dart';

class ScreenPrograms extends ConsumerStatefulWidget {
  const ScreenPrograms({super.key});

  @override
  ConsumerState<ScreenPrograms> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends ConsumerState<ScreenPrograms> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(providerTraining.notifier).loadPrograms());
  }

  @override
  Widget build(BuildContext context) {
    final trainingState = ref.watch(providerTraining);
    final canWrite = ref.watch(providerIdentity).isEmailVerified;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Mes Programmes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: canWrite ? () => _openCreateProgram(context) : null,
            tooltip:
                canWrite ? null : 'Vérifie ton email pour créer un programme',
          ),
        ],
      ),
      body: _buildBody(context, trainingState, canWrite),
    );
  }

  Widget _buildBody(
      BuildContext context, StateTraining trainingState, bool canWrite) {
    if (trainingState.status == StatusTraining.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (trainingState.status == StatusTraining.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              trainingState.errorMessage ?? 'Une erreur est survenue',
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
      );
    }

    if (trainingState.programs.isEmpty) {
      return Center(
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
            const Text(
              'Crée ton premier programme d\'entraînement',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: canWrite ? () => _openCreateProgram(context) : null,
              icon: const Icon(Icons.add),
              label: const Text('Créer un programme'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(providerTraining.notifier).loadPrograms(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trainingState.programs.length,
        itemBuilder: (context, index) {
          final program = trainingState.programs[index];
          return CardProgram(
            program: program,
            canWrite: canWrite,
            onStartSession: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              useRootNavigator: true,
              builder: (context) => const ScreenSessions(),
            ),
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
