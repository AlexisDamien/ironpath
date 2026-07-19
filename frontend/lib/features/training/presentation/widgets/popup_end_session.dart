import 'package:flutter/material.dart';

Future<bool> showEndSessionDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Terminer la séance'),
      content: const Text('Es-tu sûr de vouloir terminer cette séance ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Terminer'),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
