import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_bodymetrics.dart';
import '../../domain/state_bodymetrics.dart';
import '../../domain/models/body_measurement.dart';
import '../../domain/models/body_composition.dart';
import '../widgets/card_measurement.dart';
import '../widgets/card_composition.dart';
import '../widgets/sheet_add_metrics.dart';
import '../widgets/popup_delete_measurement.dart';
import '../widgets/popup_delete_composition.dart';
import '../widgets/popup_connected_device.dart';

class ScreenBodyMetrics extends ConsumerStatefulWidget {
  const ScreenBodyMetrics({super.key});

  @override
  ConsumerState<ScreenBodyMetrics> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends ConsumerState<ScreenBodyMetrics>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(providerBodyMetrics.notifier).loadMeasurements();
      ref.read(providerBodyMetrics.notifier).loadCompositions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyMetricsState = ref.watch(providerBodyMetrics);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Mesures corporelles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mensurations'),
            Tab(text: 'Composition'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSheet(context),
          ),
        ],
      ),
      body: bodyMetricsState.status == StatusBodyMetrics.loading &&
              !bodyMetricsState.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMeasurementsList(context, bodyMetricsState.measurements),
                _buildCompositionsList(context, bodyMetricsState.compositions),
              ],
            ),
    );
  }

  Widget _buildMeasurementsList(
      BuildContext context, List<BodyMeasurement> measurements) {
    if (measurements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune mensuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoute ta première mesure',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(providerBodyMetrics.notifier).loadMeasurements(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: measurements.length,
        itemBuilder: (context, index) {
          final measurement = measurements[index];
          return CardMeasurement(
            key: ValueKey(measurement.id),
            measurement: measurement,
            isEditable: measurement.isEditable,
            onEdit: () => _showEditMeasurementSheet(context, measurement),
            onDelete: () =>
                showPopupDeleteMeasurement(context, ref, measurement),
          );
        },
      ),
    );
  }

  Widget _buildCompositionsList(
      BuildContext context, List<BodyComposition> compositions) {
    if (compositions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune composition',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoute ta première composition corporelle',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(providerBodyMetrics.notifier).loadCompositions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: compositions.length,
        itemBuilder: (context, index) {
          final composition = compositions[index];
          return CardComposition(
            key: ValueKey(composition.id),
            composition: composition,
            isEditable: composition.isEditable,
            onEdit: () => _showEditCompositionSheet(context, composition),
            onDelete: () =>
                showPopupDeleteComposition(context, ref, composition),
            onConnectedDevice: () => showPopupConnectedDevice(
              context,
              composition,
              onCreateManual: () =>
                  _showEditCompositionSheet(context, composition),
            ),
          );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SheetAddMetrics(
        selectedTab: _tabController.index,
      ),
    );
  }

  void _showEditMeasurementSheet(
      BuildContext context, BodyMeasurement measurement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SheetAddMetrics(
        selectedTab: 0,
        measurementToEdit: measurement,
      ),
    );
  }

  void _showEditCompositionSheet(
      BuildContext context, BodyComposition composition) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SheetAddMetrics(
        selectedTab: 1,
        compositionToEdit: composition,
      ),
    );
  }
}
