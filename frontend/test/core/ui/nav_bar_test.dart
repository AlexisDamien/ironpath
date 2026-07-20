import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ironpath/core/ui/nav_bar.dart';

void main() {
  testWidgets('affiche les cinq destinations et transmet l’index',
      (tester) async {
    var selected = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NavBar(
            currentIndex: 0,
            onTap: (index) => selected = index,
          ),
        ),
      ),
    );

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Programmes'), findsOneWidget);
    expect(find.text('Séances'), findsOneWidget);
    expect(find.text('Mesures'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    await tester.tap(find.text('Mesures'));
    await tester.pump();

    expect(selected, 3);
  });
}
