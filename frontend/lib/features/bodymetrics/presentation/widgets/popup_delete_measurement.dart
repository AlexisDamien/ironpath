import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/format_date.dart';
import '../../domain/models/body_measurement.dart';
import '../providers/provider_bodymetrics.dart';

void showPopupDeleteMeasurement(
  BuildContext context,
  WidgetRef ref,
  BodyMeasurement measurement,
) {
  final formattedDate = formatDate(measurement.recordedAt);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer la mesure'),
      content: Text(
        'Supprimer la mesure du $formattedDate ? Cette action est irréversible.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            ref
                .read(providerBodyMetrics.notifier)
                .deleteMeasurement(measurement.id);
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
}
