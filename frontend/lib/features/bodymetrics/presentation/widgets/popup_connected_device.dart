import 'package:flutter/material.dart';
import '../../domain/models/body_composition.dart';

void showPopupConnectedDevice(BuildContext context, BodyComposition composition,
    {required VoidCallback onCreateManual}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Données balance connectée'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ces données proviennent d\'une balance connectée et ne peuvent pas être modifiées directement.',
          ),
          SizedBox(height: 16),
          Text(
            'Voulez-vous créer une nouvelle entrée manuelle basée sur ces données ?',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCreateManual();
          },
          child: const Text('Créer une entrée manuelle'),
        ),
      ],
    ),
  );
}
