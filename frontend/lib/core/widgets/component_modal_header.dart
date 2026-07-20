import 'package:flutter/material.dart';

class ComponentModalHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;
  final String closeTooltip;
  final bool closeEnabled;

  const ComponentModalHeader({
    super.key,
    required this.title,
    this.onClose,
    this.closeTooltip = 'Annuler et fermer',
    this.closeEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: closeTooltip,
          onPressed: closeEnabled
              ? onClose ?? () => Navigator.of(context).pop()
              : null,
        ),
      ],
    );
  }
}
