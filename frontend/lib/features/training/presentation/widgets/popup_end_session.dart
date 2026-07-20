import 'package:flutter/material.dart';

import '../../../../core/widgets/component_modal_header.dart';

Future<bool> showEndSessionDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 12, 8, 0),
      title: ComponentModalHeader(
        title: 'Terminer la séance',
        onClose: () => Navigator.of(dialogContext).pop(false),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Es-tu sûr de vouloir terminer cette séance ?'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text('Terminer la séance'),
          ),
        ],
      ),
    ),
  );

  return confirmed ?? false;
}
