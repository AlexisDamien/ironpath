import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ironpath/core/widgets/component_metric_value.dart';

void main() {
  testWidgets('affiche la valeur et son libellé', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ComponentMetricValue(value: '82 kg', label: 'Poids'),
        ),
      ),
    );

    expect(find.text('82 kg'), findsOneWidget);
    expect(find.text('Poids'), findsOneWidget);
  });

  testWidgets('résiste à une grande échelle de texte', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: ComponentMetricValue(
              value: '123456789 kg',
              label: 'Valeur très longue',
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
