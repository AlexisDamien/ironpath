import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/format_date.dart';
import '../../../../core/widgets/component_modal_header.dart';
import '../../domain/models/body_composition.dart';
import '../providers/provider_bodymetrics.dart';

void showPopupDeleteComposition(
  BuildContext context,
  WidgetRef ref,
  BodyComposition composition,
) {
  final formattedDate = formatDate(composition.recordedAt);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 12, 8, 0),
      title: const ComponentModalHeader(title: 'Supprimer la composition'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Supprimer la composition du $formattedDate ? Cette action est irréversible.',
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref
                  .read(providerBodyMetrics.notifier)
                  .deleteComposition(composition.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Supprimer'),
          ),
        ],
      ),
    ),
  );
}
