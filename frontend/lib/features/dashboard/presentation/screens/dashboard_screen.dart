import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../training/domain/training_state.dart';
import '../../../training/presentation/providers/training_provider.dart';
import '../../../bodymetrics/presentation/providers/bodymetrics_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(trainingProvider.notifier).loadPrograms();
      ref.read(trainingProvider.notifier).loadSessionHistory();
      ref.read(bodyMetricsProvider.notifier).loadMeasurements();
      ref.read(bodyMetricsProvider.notifier).loadCompositions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trainingState = ref.watch(trainingProvider);
    final bodyMetricsState = ref.watch(bodyMetricsProvider);

    final lastSession = trainingState.sessionHistory.isNotEmpty
        ? trainingState.sessionHistory.first
        : null;


    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'IronPath',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(trainingProvider.notifier).loadPrograms();
          await ref.read(trainingProvider.notifier).loadSessionHistory();
          await ref.read(bodyMetricsProvider.notifier).loadMeasurements();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (trainingState.activeSession != null)
              _buildActiveSessionBanner(context),
            const SizedBox(height: 16),
            _buildLastMetricsCard(context),
            const SizedBox(height: 16),
            _buildLastSessionCard(context, lastSession),
            const SizedBox(height: 16),
            _buildProgramsOverview(context, trainingState),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/session'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.fitness_center,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Session en cours — Appuie pour continuer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLastMetricsCard(BuildContext context) {
    final bodyMetricsState = ref.watch(bodyMetricsProvider);

    final lastMeasurement = bodyMetricsState.measurements.isNotEmpty
        ? bodyMetricsState.measurements.first
        : null;

    final lastComposition = bodyMetricsState.compositions.isNotEmpty
        ? bodyMetricsState.compositions.first
        : null;

    if (lastMeasurement == null && lastComposition == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dernières mesures',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () => context.go('/progress'),
                    child: const Text('Voir tout'),
                  ),
                ],
              ),
              const Text(
                'Aucune mesure enregistrée',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dernières mesures',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: () => context.go('/progress'),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            if (lastMeasurement != null) ...[
              const SizedBox(height: 8),
              Text(
                'Mensurations — ${_formatDate(lastMeasurement.recordedAt)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (lastMeasurement.weight != null)
                    _buildStatItem(
                        context, '${lastMeasurement.weight} kg', 'Poids'),
                  if (lastMeasurement.chest != null)
                    _buildStatItem(
                        context, '${lastMeasurement.chest} cm', 'Poitrine'),
                  if (lastMeasurement.waist != null)
                    _buildStatItem(
                        context, '${lastMeasurement.waist} cm', 'Taille'),
                  if (lastMeasurement.hips != null)
                    _buildStatItem(
                        context, '${lastMeasurement.hips} cm', 'Hanches'),
                ],
              ),
            ],
            if (lastMeasurement != null && lastComposition != null)
              const Divider(height: 24),
            if (lastComposition != null) ...[
              Text(
                'Composition — ${_formatDate(lastComposition.recordedAt)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (lastComposition.bmi != null)
                    _buildStatItem(context,
                        '${lastComposition.bmi!.toStringAsFixed(1)}', 'BMI'),
                  if (lastComposition.bodyFat != null)
                    _buildStatItem(
                        context, '${lastComposition.bodyFat}%', 'Masse grasse'),
                  if (lastComposition.muscleMass != null)
                    _buildStatItem(
                        context, '${lastComposition.muscleMass} kg', 'Muscle'),
                  if (lastComposition.metabolicAge != null)
                    _buildStatItem(context,
                        '${lastComposition.metabolicAge} ans', 'Âge métabo.'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLastSessionCard(BuildContext context, dynamic lastSession) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dernière session',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (lastSession == null)
              const Text(
                'Aucune session enregistrée',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lastSession.name ?? 'Session libre',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lastSession.sets.length} set${lastSession.sets.length > 1 ? 's' : ''} • ${_formatDate(lastSession.startedAt)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramsOverview(
      BuildContext context, TrainingState trainingState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mes programmes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/programs'),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (trainingState.programs.isEmpty)
              const Text(
                'Aucun programme créé',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...trainingState.programs.take(3).map(
                    (program) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(program.name),
                      subtitle: Text(
                        '${program.exercises.length} exercice${program.exercises.length > 1 ? 's' : ''}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.go('/programs'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
