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
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
