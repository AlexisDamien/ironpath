import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../bodymetrics/presentation/providers/provider_bodymetrics.dart';
import '../../../training/presentation/providers/provider_training.dart';
import '../widgets/card_active_session.dart';
import '../widgets/card_last_metrics.dart';
import '../widgets/card_last_session.dart';
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
    Future.microtask(() {
      ref.read(providerTraining.notifier).loadPrograms();
      ref.read(providerTraining.notifier).loadSessionHistory();
      ref.read(providerTraining.notifier).loadActiveSession();
      ref.read(providerBodyMetrics.notifier).loadMeasurements();
      ref.read(providerBodyMetrics.notifier).loadCompositions();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(providerTraining.notifier).loadPrograms(),
      ref.read(providerTraining.notifier).loadSessionHistory(),
      ref.read(providerTraining.notifier).loadActiveSession(),
      ref.read(providerBodyMetrics.notifier).loadMeasurements(),
      ref.read(providerBodyMetrics.notifier).loadCompositions(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final trainingState = ref.watch(providerTraining);
    final bodyMetricsState = ref.watch(providerBodyMetrics);
    final lastSession = trainingState.sessionHistory.isEmpty
        ? null
        : trainingState.sessionHistory.first;
    final lastMeasurement = bodyMetricsState.measurements.isEmpty
        ? null
        : bodyMetricsState.measurements.first;
    final lastComposition = bodyMetricsState.compositions.isEmpty
        ? null
        : bodyMetricsState.compositions.first;

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
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (trainingState.activeSession != null)
              CardActiveSession(
                onTap: () => context.go('/session'),
              ),
            if (trainingState.activeSession != null) const SizedBox(height: 16),
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
}
