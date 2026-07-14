import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/body_composition.dart';
import '../providers/provider_bodymetrics.dart';

void showPopupDeleteComposition(
    BuildContext context, WidgetRef ref, BodyComposition composition) {
  final formattedDate =
      '${composition.recordedAt.day.toString().padLeft(2, '0')}/${composition.recordedAt.month.toString().padLeft(2, '0')}/${composition.recordedAt.year}';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer la composition'),
      content: Text(
          'Supprimer la composition du $formattedDate ? Cette action est irréversible.'),
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
                .deleteComposition(composition.id);
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
