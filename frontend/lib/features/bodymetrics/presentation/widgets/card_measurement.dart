import 'package:flutter/material.dart';
import '../../../../core/utils/format_date.dart';
import '../../domain/models/body_measurement.dart';
import 'chip_metric.dart';

class CardMeasurement extends StatelessWidget {
  final BodyMeasurement measurement;
  final bool isEditable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CardMeasurement({
    super.key,
    required this.measurement,
    required this.isEditable,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _buildActions(BuildContext context) {
    return Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (measurement.weight != null)
          Semantics(
            label: 'Poids : ${measurement.weight} kilogrammes',
            child: ExcludeSemantics(
              child: Text(
                '${measurement.weight} kg',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        if (isEditable)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: Theme.of(context).colorScheme.primary,
            tooltip: 'Modifier cette mesure',
            onPressed: onEdit,
          ),
        if (isEditable)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Theme.of(context).colorScheme.error,
            tooltip: 'Supprimer cette mesure',
            onPressed: onDelete,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final useColumn = constraints.maxWidth < 420 || textScale > 1.3;
                final date = Text(
                  formatDate(measurement.recordedAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                );
                if (useColumn) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      date,
                      const SizedBox(height: 4),
                      _buildActions(context),
                    ],
                  );
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: date),
                    const SizedBox(width: 8),
                    _buildActions(context),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (measurement.chest != null)
                  ChipMetric(
                    label: 'Poitrine',
                    value: '${measurement.chest} cm',
                  ),
                if (measurement.waist != null)
                  ChipMetric(label: 'Taille', value: '${measurement.waist} cm'),
                if (measurement.hips != null)
                  ChipMetric(label: 'Hanches', value: '${measurement.hips} cm'),
                if (measurement.leftArm != null)
                  ChipMetric(
                    label: 'Bras G',
                    value: '${measurement.leftArm} cm',
                  ),
                if (measurement.rightArm != null)
                  ChipMetric(
                    label: 'Bras D',
                    value: '${measurement.rightArm} cm',
                  ),
                if (measurement.leftThigh != null)
                  ChipMetric(
                    label: 'Cuisse G',
                    value: '${measurement.leftThigh} cm',
                  ),
                if (measurement.rightThigh != null)
                  ChipMetric(
                    label: 'Cuisse D',
                    value: '${measurement.rightThigh} cm',
                  ),
                if (measurement.leftCalf != null)
                  ChipMetric(
                    label: 'Mollet G',
                    value: '${measurement.leftCalf} cm',
                  ),
                if (measurement.rightCalf != null)
                  ChipMetric(
                    label: 'Mollet D',
                    value: '${measurement.rightCalf} cm',
                  ),
              ],
            ),
            if (measurement.notes != null &&
                measurement.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                measurement.notes!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
