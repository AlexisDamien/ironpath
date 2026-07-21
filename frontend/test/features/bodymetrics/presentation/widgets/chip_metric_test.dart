import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/bodymetrics/presentation/widgets/chip_metric.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('displays the provided label and value', (tester) async {
    await tester.pumpWidget(
      wrap(const ChipMetric(label: 'Masse grasse', value: '15%')),
    );

    expect(find.text('Masse grasse'), findsOneWidget);
    expect(find.text('15%'), findsOneWidget);
  });

  testWidgets('renders different label/value pairs correctly', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const ChipMetric(label: 'Eau', value: '55%')),
    );

    expect(find.text('Eau'), findsOneWidget);
    expect(find.text('55%'), findsOneWidget);
    expect(find.text('Masse grasse'), findsNothing);
  });
}
