import 'package:flutter/material.dart';

import '../../../../core/widgets/component_metric_value.dart';
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (composition.bmi != null)
                  Expanded(
                    child: ComponentMetricValue(
                      value: composition.bmi!.toStringAsFixed(1),
                      label: 'IMC',
                    ),
                  ),
                if (composition.bmr != null)
                  Expanded(
                    child: ComponentMetricValue(
                      value: '${composition.bmr}',
                      label: 'BMR (kcal)',
                    ),
                  ),
                if (composition.metabolicAge != null)
                  Expanded(
                    child: ComponentMetricValue(
                      value: '${composition.metabolicAge} ans',
                      label: 'Âge métabo.',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
