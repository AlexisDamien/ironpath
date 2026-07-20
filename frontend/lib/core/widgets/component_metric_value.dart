import 'package:flutter/material.dart';

class ComponentMetricValue extends StatelessWidget {
  final String value;
  final String label;
  final CrossAxisAlignment crossAxisAlignment;

  const ComponentMetricValue({
    super.key,
    required this.value,
    required this.label,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 56, maxWidth: 128),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
