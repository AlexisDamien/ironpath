import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../training/presentation/providers/provider_training.dart';
import '../../../bodymetrics/presentation/providers/provider_bodymetrics.dart';
import '../widgets/card_last_session.dart';
import '../widgets/card_last_metrics.dart';
import '../widgets/card_programs_overview.dart';

class ScreenDashboard extends ConsumerStatefulWidget {
  const ScreenDashboard({super.key});

  @override
  ConsumerState<ScreenDashboard> createState() => _ScreenDashboardState();
}

class _ScreenDashboardState extends ConsumerState<ScreenDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(providerTraining.notifier).loadPrograms();
      ref.read(providerTraining.notifier).loadSessionHistory();
      ref.read(providerTraining.notifier).loadActiveSession();
      ref.read(providerBodyMetrics.notifier).loadMeasurements();
      ref.read(providerBodyMetrics.notifier).loadCompositions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trainingState = ref.watch(providerTraining);
    final bodyMetricsState = ref.watch(providerBodyMetrics);

    final lastSession = trainingState.sessionHistory.isNotEmpty
        ? trainingState.sessionHistory.first
        : null;

    final lastMeasurement = bodyMetricsState.measurements.isNotEmpty
        ? bodyMetricsState.measurements.first
        : null;

    final lastComposition = bodyMetricsState.compositions.isNotEmpty
        ? bodyMetricsState.compositions.first
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
          await ref.read(providerTraining.notifier).loadPrograms();
          await ref.read(providerTraining.notifier).loadSessionHistory();
          await ref.read(providerBodyMetrics.notifier).loadMeasurements();
          await ref.read(providerBodyMetrics.notifier).loadCompositions();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (trainingState.activeSession != null)
              _buildActiveSessionBanner(context),
            const SizedBox(height: 16),
            CardLastMetrics(
              lastMeasurement: lastMeasurement,
              lastComposition: lastComposition,
            ),
            const SizedBox(height: 16),
            CardLastSession(lastSession: lastSession),
            const SizedBox(height: 16),
            CardProgramsOverview(programs: trainingState.programs),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/session'),
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
}
