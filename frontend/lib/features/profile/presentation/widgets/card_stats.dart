import 'package:flutter/material.dart';
import '../../../bodymetrics/domain/models/body_composition.dart';

class CardStats extends StatelessWidget {
  final BodyComposition composition;

  const CardStats({super.key, required this.composition});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques corporelles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (composition.bmi != null)
                  Expanded(
                    child: _buildStatItem(
                      context,
                      composition.bmi!.toStringAsFixed(1),
                      'IMC',
                    ),
                  ),
                if (composition.bmr != null)
                  Expanded(
                    child: _buildStatItem(
                      context,
                      '${composition.bmr}',
                      'BMR (kcal)',
                    ),
                  ),
                if (composition.metabolicAge != null)
                  Expanded(
                    child: _buildStatItem(
                      context,
                      '${composition.metabolicAge} ans',
                      'Âge métabo.',
                    ),
                  ),
              ],
            ),
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
}
