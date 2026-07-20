import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ironpath/core/widgets/component_rest_timer.dart';
import 'package:ironpath/features/training/presentation/providers/provider_rest_timer.dart';

Finder _semanticsWithLabel(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is Semantics && widget.properties.label == label,
    description: 'Semantics avec le label "$label"',
  );
}

void main() {
  testWidgets('affiche la durée planifiée hors session', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ComponentRestTimer(id: 'set-1', initialSeconds: 90),
          ),
        ),
      ),
    );

    expect(find.text('01:30'), findsOneWidget);
    expect(
      _semanticsWithLabel('Temps de repos planifié : 01:30.'),
      findsOneWidget,
    );
  });

  testWidgets('affiche le temps restant pour le propriétaire', (tester) async {
    final notifier = ProviderRestTimerNotifier();
    notifier.setDuration(45, 'set-1');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerRestTimer.overrideWith((ref) => notifier),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ComponentRestTimer(id: 'set-1', initialSeconds: 90),
          ),
        ),
      ),
    );

    expect(find.text('00:45'), findsOneWidget);
    expect(
      _semanticsWithLabel('Temps de repos restant : 00:45.'),
      findsOneWidget,
    );
  });
}
