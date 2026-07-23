import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ironpath/features/training/presentation/widgets/card_program.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  testWidgets('affiche le programme et appelle onSelect', (tester) async {
    var selected = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CardProgram(
              program: programFixture(),
              onSelect: () => selected = true,
              onEdit: () {},
              canWrite: true,
              isSelected: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Push'), findsOneWidget);
    expect(find.text('1 exercice'), findsOneWidget);
    expect(find.text('Appuyer pour sélectionner'), findsOneWidget);

    await tester.tap(find.text('Push'));
    expect(selected, isTrue);
  });

  testWidgets('annonce et affiche l’état sélectionné', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CardProgram(
              program: programFixture(),
              onSelect: () {},
              onEdit: () {},
              canWrite: true,
              isSelected: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sélectionné'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.selected == true &&
            widget.properties.label?.startsWith('Push, ') == true,
        description: 'Sémantique sélectionnée de la carte programme',
      ),
      findsOneWidget,
    );
  });

  testWidgets('désactive les actions d’écriture sans email vérifié',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CardProgram(
              program: programFixture(),
              onSelect: () {},
              onEdit: () {},
              canWrite: false,
              isSelected: false,
            ),
          ),
        ),
      ),
    );

    final edit = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.edit_outlined),
    );
    final delete = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.delete_outline),
    );
    expect(edit.onPressed, isNull);
    expect(delete.onPressed, isNull);
  });

  testWidgets(
      'affiche le détail des exercices au clic sur "Voir le détail des exercices"',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CardProgram(
              program: programFixture(),
              onSelect: () {},
              onEdit: () {},
              canWrite: true,
              isSelected: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('1 série'), findsNothing);

    await tester.tap(find.text('Voir le détail des exercices'));
    await tester.pumpAndSettle();

    expect(find.text('Masquer le détail'), findsOneWidget);
    expect(find.text('1 série'), findsOneWidget);
  });

  testWidgets(
      'le clic sur le dropdown n\'appelle pas onSelect (action indépendante)',
      (tester) async {
    var selected = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CardProgram(
              program: programFixture(),
              onSelect: () => selected = true,
              onEdit: () {},
              canWrite: true,
              isSelected: false,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Voir le détail des exercices'));
    await tester.pumpAndSettle();

    expect(selected, isFalse);
  });
}
