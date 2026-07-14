import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../bodymetrics/domain/models/body_measurement.dart';
import '../../../bodymetrics/domain/models/body_composition.dart';

class CardLastMetrics extends ConsumerWidget {
  final BodyMeasurement? lastMeasurement;
  final BodyComposition? lastComposition;

  const CardLastMetrics({
    super.key,
    this.lastMeasurement,
    this.lastComposition,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (lastMeasurement == null && lastComposition == null) {
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () => context.go('/bodymetrics'),
                    child: const Text('Voir tout'),
                  ),
                ],
              ),
              const Text(
                'Aucune mesure enregistrée',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: () => context.go('/bodymetrics'),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            if (lastMeasurement != null) ...[
              const SizedBox(height: 8),
              Text(
                'Mensurations — ${_formatDate(lastMeasurement!.recordedAt)}',
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
                  if (lastMeasurement!.weight != null)
                    _buildStatItem(
                        context, '${lastMeasurement!.weight} kg', 'Poids'),
                  if (lastMeasurement!.chest != null)
                    _buildStatItem(
                        context, '${lastMeasurement!.chest} cm', 'Poitrine'),
                  if (lastMeasurement!.waist != null)
                    _buildStatItem(
                        context, '${lastMeasurement!.waist} cm', 'Taille'),
                  if (lastMeasurement!.hips != null)
                    _buildStatItem(
                        context, '${lastMeasurement!.hips} cm', 'Hanches'),
                ],
              ),
            ],
            if (lastMeasurement != null && lastComposition != null)
              const Divider(height: 24),
            if (lastComposition != null) ...[
              Text(
                'Composition — ${_formatDate(lastComposition!.recordedAt)}',
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
                  if (lastComposition!.bmi != null)
                    _buildStatItem(context,
                        lastComposition!.bmi!.toStringAsFixed(1), 'BMI'),
                  if (lastComposition!.bodyFat != null)
                    _buildStatItem(context, '${lastComposition!.bodyFat}%',
                        'Masse grasse'),
                  if (lastComposition!.muscleMass != null)
                    _buildStatItem(
                        context, '${lastComposition!.muscleMass} kg', 'Muscle'),
                  if (lastComposition!.metabolicAge != null)
                    _buildStatItem(context,
                        '${lastComposition!.metabolicAge} ans', 'Âge métabo.'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
