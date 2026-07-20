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

  Widget _buildActions(BuildContext context) {
    return Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (composition.bmi != null)
          Semantics(
            label:
                'Indice de masse corporelle : ${composition.bmi!.toStringAsFixed(1)}',
            child: ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'IMC ${composition.bmi!.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        if (isEditable && composition.isManual)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: Theme.of(context).colorScheme.primary,
            tooltip: 'Modifier cette composition',
            onPressed: onEdit,
          ),
        if (isEditable && !composition.isManual)
          IconButton(
            icon: const Icon(Icons.info_outline),
            color: Theme.of(context).colorScheme.primary,
            tooltip: 'Voir l’appareil connecté',
            onPressed: onConnectedDevice,
          ),
        if (isEditable)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Theme.of(context).colorScheme.error,
            tooltip: 'Supprimer cette composition',
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
                final useColumn = constraints.maxWidth < 430 || textScale > 1.3;
                final date = Text(
                  formatDate(composition.recordedAt),
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
                if (composition.bodyFat != null)
                  ChipMetric(
                    label: 'Masse grasse',
                    value: '${composition.bodyFat}%',
                  ),
                if (composition.skeletalMuscle != null)
                  ChipMetric(
                    label: 'Muscle squelettique',
                    value: '${composition.skeletalMuscle}%',
                  ),
                if (composition.bodyWater != null)
                  ChipMetric(label: 'Eau', value: '${composition.bodyWater}%'),
                if (composition.muscleMass != null)
                  ChipMetric(
                    label: 'Masse musculaire',
                    value: '${composition.muscleMass} kg',
                  ),
                if (composition.boneMass != null)
                  ChipMetric(
                    label: 'Masse osseuse',
                    value: '${composition.boneMass} kg',
                  ),
                if (composition.visceralFat != null)
                  ChipMetric(
                    label: 'Graisse viscérale',
                    value: '${composition.visceralFat}',
                  ),
                if (composition.bmr != null)
                  ChipMetric(
                    label: 'Métabolisme de base',
                    value: '${composition.bmr} kcal',
                  ),
                if (composition.metabolicAge != null)
                  ChipMetric(
                    label: 'Âge métabolique',
                    value: '${composition.metabolicAge} ans',
                  ),
              ],
            ),
            if (composition.notes != null &&
                composition.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                composition.notes!,
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
