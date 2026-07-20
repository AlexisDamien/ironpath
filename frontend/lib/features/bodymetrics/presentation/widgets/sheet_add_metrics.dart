import 'package:flutter/material.dart';

import '../../../../core/widgets/component_modal_header.dart';
import '../../domain/models/body_measurement.dart';
import '../../domain/models/body_composition.dart';
import 'form_measurement.dart';
import 'form_composition.dart';

class SheetAddMetrics extends StatefulWidget {
  final int selectedTab;
  final BodyMeasurement? measurementToEdit;
  final BodyComposition? compositionToEdit;

  const SheetAddMetrics({
    super.key,
    required this.selectedTab,
    this.measurementToEdit,
    this.compositionToEdit,
  });

  @override
  State<SheetAddMetrics> createState() => _SheetAddMetricsState();
}

class _SheetAddMetricsState extends State<SheetAddMetrics>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.selectedTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing =
        widget.measurementToEdit != null || widget.compositionToEdit != null;

    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 8, 0),
                child: ComponentModalHeader(
                  title: isEditing
                      ? 'Modifier la mesure'
                      : 'Ajouter une mesure',
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Mensurations'),
                  Tab(text: 'Composition'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    FormMeasurement(
                      measurementToEdit: widget.measurementToEdit,
                    ),
                    FormComposition(
                      compositionToEdit: widget.compositionToEdit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
