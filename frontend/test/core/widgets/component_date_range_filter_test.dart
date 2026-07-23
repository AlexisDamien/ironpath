import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/core/widgets/component_date_range_filter.dart';

void main() {
  group('isDateWithinRange', () {
    test('renvoie true quand range est null (aucun filtre actif)', () {
      expect(isDateWithinRange(DateTime(2026, 3, 10), null), isTrue);
    });

    test('renvoie true pour une date à l\'intérieur de la plage', () {
      final range = DateTimeRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 31),
      );
      expect(isDateWithinRange(DateTime(2026, 3, 15), range), isTrue);
    });

    test('renvoie true pour les bornes incluses', () {
      final range = DateTimeRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 31),
      );
      expect(isDateWithinRange(DateTime(2026, 3, 1), range), isTrue);
      expect(isDateWithinRange(DateTime(2026, 3, 31), range), isTrue);
    });

    test('renvoie false pour une date avant la plage', () {
      final range = DateTimeRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 31),
      );
      expect(isDateWithinRange(DateTime(2026, 2, 28), range), isFalse);
    });

    test('renvoie false pour une date après la plage', () {
      final range = DateTimeRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 31),
      );
      expect(isDateWithinRange(DateTime(2026, 4, 1), range), isFalse);
    });

    test('ignore l\'heure, ne compare que le jour', () {
      final range = DateTimeRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 31),
      );
      expect(
        isDateWithinRange(DateTime(2026, 3, 31, 23, 59), range),
        isTrue,
      );
    });
  });

  group('ComponentDateRangeFilter', () {
    Widget wrap(Widget child) {
      return MaterialApp(home: Scaffold(body: child));
    }

    testWidgets('affiche le texte par défaut sans filtre actif', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          ComponentDateRangeFilter(
            selectedRange: null,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Filtrer par date'), findsOneWidget);
    });

    testWidgets('affiche la plage sélectionnée quand un filtre est actif', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          ComponentDateRangeFilter(
            selectedRange: DateTimeRange(
              start: DateTime(2026, 3, 1),
              end: DateTime(2026, 3, 31),
            ),
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('01/03/2026 → 31/03/2026'), findsOneWidget);
    });

    testWidgets('affiche la croix de suppression uniquement si actif', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          ComponentDateRangeFilter(
            selectedRange: null,
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.byIcon(Icons.close), findsNothing);

      await tester.pumpWidget(
        wrap(
          ComponentDateRangeFilter(
            selectedRange: DateTimeRange(
              start: DateTime(2026, 3, 1),
              end: DateTime(2026, 3, 31),
            ),
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('appelle onChanged(null) au clic sur la croix', (
      tester,
    ) async {
      DateTimeRange? received = DateTimeRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 31),
      );

      await tester.pumpWidget(
        wrap(
          StatefulBuilder(
            builder: (context, setState) {
              return ComponentDateRangeFilter(
                selectedRange: received,
                onChanged: (value) => setState(() => received = value),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(received, isNull);
    });
  });
}
