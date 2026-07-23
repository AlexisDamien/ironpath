import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/bodymetrics/domain/models/body_composition.dart';
import 'package:ironpath/features/bodymetrics/presentation/widgets/card_composition.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 600, child: child),
      ),
    );
  }

  final baseComposition = BodyComposition(
    id: 'bc-1',
    recordedAt: DateTime(2026, 3, 5),
    bodyFat: 15.0,
    bmi: 22.5,
    source: 'MANUAL',
  );

  testWidgets('displays the recorded date', (tester) async {
    await tester.pumpWidget(
      wrap(
        CardComposition(
          composition: baseComposition,
          isEditable: true,
          onEdit: () {},
          onDelete: () {},
          onConnectedDevice: () {},
        ),
      ),
    );

    expect(find.text('05/03/2026'), findsOneWidget);
  });

  testWidgets('displays a ChipMetric for each non-null measurement', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        CardComposition(
          composition: baseComposition,
          isEditable: true,
          onEdit: () {},
          onDelete: () {},
          onConnectedDevice: () {},
        ),
      ),
    );

    expect(find.text('Masse grasse'), findsOneWidget);
    expect(find.text('15.0%'), findsOneWidget);
    expect(find.text('Masse musculaire'), findsNothing);
  });

  testWidgets('shows edit and delete buttons when editable and manual', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        CardComposition(
          composition: baseComposition,
          isEditable: true,
          onEdit: () {},
          onDelete: () {},
          onConnectedDevice: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsNothing);
  });

  testWidgets('shows info icon instead of edit when not manual', (
    tester,
  ) async {
    final deviceComposition = BodyComposition(
      id: 'bc-2',
      recordedAt: DateTime(2026, 3, 5),
      source: 'DEVICE',
    );

    await tester.pumpWidget(
      wrap(
        CardComposition(
          composition: deviceComposition,
          isEditable: true,
          onEdit: () {},
          onDelete: () {},
          onConnectedDevice: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });

  testWidgets('hides action buttons when not editable', (tester) async {
    await tester.pumpWidget(
      wrap(
        CardComposition(
          composition: baseComposition,
          isEditable: false,
          onEdit: () {},
          onDelete: () {},
          onConnectedDevice: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('calls onEdit when the edit button is tapped', (tester) async {
    var editTapped = false;

    await tester.pumpWidget(
      wrap(
        CardComposition(
          composition: baseComposition,
          isEditable: true,
          onEdit: () => editTapped = true,
          onDelete: () {},
          onConnectedDevice: () {},
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pump();

    expect(editTapped, isTrue);
  });

  testWidgets('calls onDelete when the delete button is tapped', (
    tester,
  ) async {
    var deleteTapped = false;

    await tester.pumpWidget(
      wrap(
        CardComposition(
          composition: baseComposition,
          isEditable: true,
          onEdit: () {},
          onDelete: () => deleteTapped = true,
          onConnectedDevice: () {},
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(deleteTapped, isTrue);
  });

  testWidgets('displays notes when present and non-empty', (tester) async {
    final withNotes = BodyComposition(
      id: 'bc-3',
      recordedAt: DateTime(2026, 3, 5),
      notes: 'Mesure du matin',
    );

    await tester.pumpWidget(
      wrap(
        CardComposition(
          composition: withNotes,
          isEditable: true,
          onEdit: () {},
          onDelete: () {},
          onConnectedDevice: () {},
        ),
      ),
    );

    expect(find.text('Mesure du matin'), findsOneWidget);
  });

  testWidgets('does not display the IMC badge when bmi is null', (
    tester,
  ) async {
    final noBmi = BodyComposition(id: 'bc-4', recordedAt: DateTime(2026, 3, 5));

    await tester.pumpWidget(
      wrap(
        CardComposition(
          composition: noBmi,
          isEditable: true,
          onEdit: () {},
          onDelete: () {},
          onConnectedDevice: () {},
        ),
      ),
    );

    expect(find.textContaining('IMC'), findsNothing);
  });
}
