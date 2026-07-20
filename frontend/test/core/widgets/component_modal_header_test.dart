import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ironpath/core/widgets/component_modal_header.dart';

void main() {
  testWidgets('affiche le titre et appelle onClose', (tester) async {
    var closed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ComponentModalHeader(
            title: 'Modifier le profil',
            onClose: () => closed = true,
          ),
        ),
      ),
    );

    expect(find.text('Modifier le profil'), findsOneWidget);
    expect(find.byTooltip('Annuler et fermer'), findsOneWidget);

    await tester.tap(find.byTooltip('Annuler et fermer'));
    expect(closed, isTrue);
  });

  testWidgets('désactive la fermeture lorsque closeEnabled vaut false',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ComponentModalHeader(
            title: 'Envoi en cours',
            closeEnabled: false,
          ),
        ),
      ),
    );

    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.onPressed, isNull);
  });
}
