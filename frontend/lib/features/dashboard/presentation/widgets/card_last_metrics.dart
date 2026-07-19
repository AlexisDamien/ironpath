import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/format_date.dart';
import '../../../../core/widgets/component_metric_value.dart';
import '../../../bodymetrics/domain/models/body_composition.dart';
import '../../../bodymetrics/domain/models/body_measurement.dart';

class CardLastMetrics extends StatelessWidget {
  final BodyMeasurement? lastMeasurement;
  final BodyComposition? lastComposition;

  const CardLastMetrics({
    super.key,
    this.lastMeasurement,
    this.lastComposition,
  });

  @override
  Widget build(BuildContext context) {
    final measurement = lastMeasurement;
    final composition = lastComposition;

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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/bodymetrics'),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            if (measurement == null && composition == null)
              const Text(
                'Aucune mesure enregistrée',
                style: TextStyle(color: Colors.grey),
              ),
            if (measurement != null) ...[
              const SizedBox(height: 8),
              Text(
                'Mensurations — ${formatDate(measurement.recordedAt)}',
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
                  if (measurement.weight != null)
                    ComponentMetricValue(
                      value: '${measurement.weight} kg',
                      label: 'Poids',
                    ),
                  if (measurement.chest != null)
                    ComponentMetricValue(
                      value: '${measurement.chest} cm',
                      label: 'Poitrine',
                    ),
                  if (measurement.waist != null)
                    ComponentMetricValue(
                      value: '${measurement.waist} cm',
                      label: 'Taille',
                    ),
                  if (measurement.hips != null)
                    ComponentMetricValue(
                      value: '${measurement.hips} cm',
                      label: 'Hanches',
                    ),
                ],
              ),
            ],
            if (measurement != null && composition != null)
              const Divider(height: 24),
            if (composition != null) ...[
              Text(
                'Composition — ${formatDate(composition.recordedAt)}',
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
                  if (composition.bmi != null)
                    ComponentMetricValue(
                      value: composition.bmi!.toStringAsFixed(1),
                      label: 'IMC',
                    ),
                  if (composition.bodyFat != null)
                    ComponentMetricValue(
                      value: '${composition.bodyFat}%',
                      label: 'Masse grasse',
                    ),
                  if (composition.muscleMass != null)
                    ComponentMetricValue(
                      value: '${composition.muscleMass} kg',
                      label: 'Muscle',
                    ),
                  if (composition.metabolicAge != null)
                    ComponentMetricValue(
                      value: '${composition.metabolicAge} ans',
                      label: 'Âge métabo.',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
