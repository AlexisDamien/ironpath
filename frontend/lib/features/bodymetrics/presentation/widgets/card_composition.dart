import 'package:flutter/material.dart';
import '../../../../core/utils/format_date.dart';
import '../../domain/models/body_composition.dart';
import 'chip_metric.dart';

class CardComposition extends StatelessWidget {
  final BodyComposition composition;
  final bool isEditable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onConnectedDevice;

  const CardComposition({
    super.key,
    required this.composition,
    required this.isEditable,
    required this.onEdit,
    required this.onDelete,
    required this.onConnectedDevice,
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
                  formatDate(composition.recordedAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    if (composition.bmi != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'BMI ${composition.bmi!.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (isEditable) ...[
                      const SizedBox(width: 8),
                      if (composition.isManual)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: onConnectedDevice,
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
                if (composition.bodyFat != null)
                  ChipMetric(
                      label: 'Masse grasse', value: '${composition.bodyFat}%'),
                if (composition.skeletalMuscle != null)
                  ChipMetric(
                      label: 'Muscle squelettique',
                      value: '${composition.skeletalMuscle}%'),
                if (composition.bodyWater != null)
                  ChipMetric(label: 'Eau', value: '${composition.bodyWater}%'),
                if (composition.muscleMass != null)
                  ChipMetric(
                      label: 'Masse musculaire',
                      value: '${composition.muscleMass} kg'),
                if (composition.boneMass != null)
                  ChipMetric(
                      label: 'Masse osseuse',
                      value: '${composition.boneMass} kg'),
                if (composition.visceralFat != null)
                  ChipMetric(
                      label: 'Graisse viscérale',
                      value: '${composition.visceralFat}'),
                if (composition.bmr != null)
                  ChipMetric(label: 'BMR', value: '${composition.bmr} kcal'),
                if (composition.metabolicAge != null)
                  ChipMetric(
                      label: 'Âge métabolique',
                      value: '${composition.metabolicAge} ans'),
              ],
            ),
            if (composition.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                composition.notes!,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
