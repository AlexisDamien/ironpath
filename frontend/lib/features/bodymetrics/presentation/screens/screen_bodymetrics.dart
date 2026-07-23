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
import '../../../identity/presentation/providers/provider_identity.dart';
import '../../../../core/widgets/component_date_range_filter.dart';

class ScreenBodyMetrics extends ConsumerStatefulWidget {
  const ScreenBodyMetrics({super.key});

  @override
  ConsumerState<ScreenBodyMetrics> createState() => _ScreenBodyMetricsState();
}

class _ScreenBodyMetricsState extends ConsumerState<ScreenBodyMetrics>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _dateFilter;

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
    final canWrite = ref.watch(providerIdentity).isEmailVerified;

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
            onPressed: canWrite ? () => _showAddSheet(context) : null,
            tooltip:
                canWrite ? null : 'Vérifie ton email pour ajouter une mesure',
          ),
        ],
      ),
      body: bodyMetricsState.status == StatusBodyMetrics.loading &&
              !bodyMetricsState.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ComponentDateRangeFilter(
                      selectedRange: _dateFilter,
                      onChanged: (range) => setState(() => _dateFilter = range),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMeasurementsList(
                        context,
                        bodyMetricsState.measurements
                            .where(
                              (measurement) => isDateWithinRange(
                                measurement.recordedAt,
                                _dateFilter,
                              ),
                            )
                            .toList(),
                        canWrite,
                      ),
                      _buildCompositionsList(
                        context,
                        bodyMetricsState.compositions
                            .where(
                              (composition) => isDateWithinRange(
                                composition.recordedAt,
                                _dateFilter,
                              ),
                            )
                            .toList(),
                        canWrite,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMeasurementsList(
    BuildContext context,
    List<BodyMeasurement> measurements,
    bool canWrite,
  ) {
    if (measurements.isEmpty) {
      final filterActive = _dateFilter != null;
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
            Text(
              filterActive
                  ? 'Aucune mensuration sur cette période'
                  : 'Aucune mensuration',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filterActive
                  ? 'Essaie une autre plage de dates'
                  : 'Ajoute ta première mesure',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final hasHistory = measurements.length > 1;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(providerBodyMetrics.notifier).loadMeasurements(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: measurements.length + (hasHistory ? 1 : 0),
        itemBuilder: (context, index) {
          if (hasHistory && index == 1) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Text(
                'Historique',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          final measurementIndex =
              (hasHistory && index > 1) ? index - 1 : index;
          final measurement = measurements[measurementIndex];
          return CardMeasurement(
            key: ValueKey(measurement.id),
            measurement: measurement,
            isEditable: measurement.isEditable && canWrite,
            onEdit: () => _showEditMeasurementSheet(context, measurement),
            onDelete: () =>
                showPopupDeleteMeasurement(context, ref, measurement),
          );
        },
      ),
    );
  }

  Widget _buildCompositionsList(
    BuildContext context,
    List<BodyComposition> compositions,
    bool canWrite,
  ) {
    if (compositions.isEmpty) {
      final filterActive = _dateFilter != null;
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
            Text(
              filterActive
                  ? 'Aucune composition sur cette période'
                  : 'Aucune composition',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filterActive
                  ? 'Essaie une autre plage de dates'
                  : 'Ajoute ta première composition corporelle',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final hasHistory = compositions.length > 1;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(providerBodyMetrics.notifier).loadCompositions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: compositions.length + (hasHistory ? 1 : 0),
        itemBuilder: (context, index) {
          if (hasHistory && index == 1) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Text(
                'Historique',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          final compositionIndex =
              (hasHistory && index > 1) ? index - 1 : index;
          final composition = compositions[compositionIndex];
          return CardComposition(
            key: ValueKey(composition.id),
            composition: composition,
            isEditable: composition.isEditable && canWrite,
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
      builder: (context) => SheetAddMetrics(selectedTab: _tabController.index),
    );
  }

  void _showEditMeasurementSheet(
    BuildContext context,
    BodyMeasurement measurement,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          SheetAddMetrics(selectedTab: 0, measurementToEdit: measurement),
    );
  }

  void _showEditCompositionSheet(
    BuildContext context,
    BodyComposition composition,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          SheetAddMetrics(selectedTab: 1, compositionToEdit: composition),
    );
  }
}
