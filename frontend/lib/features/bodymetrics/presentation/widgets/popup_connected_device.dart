import 'package:flutter/material.dart';

import '../../../../core/widgets/component_modal_header.dart';
import '../../domain/models/body_composition.dart';

void showPopupConnectedDevice(
  BuildContext context,
  BodyComposition composition, {
  required VoidCallback onCreateManual,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 12, 8, 0),
      title: const ComponentModalHeader(title: 'Données balance connectée'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ces données proviennent d’une balance connectée et ne peuvent pas être modifiées directement.',
          ),
          const SizedBox(height: 16),
          const Text(
            'Voulez-vous créer une nouvelle entrée manuelle basée sur ces données ?',
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onCreateManual();
            },
            icon: const Icon(Icons.add),
            label: const Text('Créer une entrée manuelle'),
          ),
        ],
      ),
    ),
  );
}
