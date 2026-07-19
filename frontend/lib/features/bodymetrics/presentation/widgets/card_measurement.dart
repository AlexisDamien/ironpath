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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDate(measurement.recordedAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    if (measurement.weight != null)
                      Text(
                        '${measurement.weight} kg',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    if (isEditable) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Theme.of(context).colorScheme.error,
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (measurement.chest != null)
                  ChipMetric(
                      label: 'Poitrine', value: '${measurement.chest} cm'),
                if (measurement.waist != null)
                  ChipMetric(label: 'Taille', value: '${measurement.waist} cm'),
                if (measurement.hips != null)
                  ChipMetric(label: 'Hanches', value: '${measurement.hips} cm'),
                if (measurement.leftArm != null)
                  ChipMetric(
                      label: 'Bras G', value: '${measurement.leftArm} cm'),
                if (measurement.rightArm != null)
                  ChipMetric(
                      label: 'Bras D', value: '${measurement.rightArm} cm'),
                if (measurement.leftThigh != null)
                  ChipMetric(
                      label: 'Cuisse G', value: '${measurement.leftThigh} cm'),
                if (measurement.rightThigh != null)
                  ChipMetric(
                      label: 'Cuisse D', value: '${measurement.rightThigh} cm'),
                if (measurement.leftCalf != null)
                  ChipMetric(
                      label: 'Mollet G', value: '${measurement.leftCalf} cm'),
                if (measurement.rightCalf != null)
                  ChipMetric(
                      label: 'Mollet D', value: '${measurement.rightCalf} cm'),
              ],
            ),
            if (measurement.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                measurement.notes!,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
