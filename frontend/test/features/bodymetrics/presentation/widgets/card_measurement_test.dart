import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/bodymetrics/domain/models/body_measurement.dart';
import 'package:ironpath/features/bodymetrics/presentation/widgets/card_measurement.dart';

void main() {
  Widget wrap(Widget child, {double width = 600}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, child: child),
      ),
    );
  }

  final baseMeasurement = BodyMeasurement(
    id: 'bm-1',
    recordedAt: DateTime(2026, 3, 5),
    weight: 80.5,
  );

  testWidgets('displays the recorded date', (tester) async {
    await tester.pumpWidget(
      wrap(
        CardMeasurement(
          measurement: baseMeasurement,
          isEditable: true,
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );

    expect(find.text('05/03/2026'), findsOneWidget);
  });

  testWidgets('displays the weight when present', (tester) async {
    await tester.pumpWidget(
      wrap(
        CardMeasurement(
          measurement: baseMeasurement,
          isEditable: true,
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );

    expect(find.text('80.5 kg'), findsOneWidget);
  });

  testWidgets('does not display weight when absent', (tester) async {
    final withoutWeight = BodyMeasurement(
      id: 'bm-2',
      recordedAt: DateTime(2026, 3, 5),
    );

    await tester.pumpWidget(
      wrap(
        CardMeasurement(
          measurement: withoutWeight,
          isEditable: true,
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );

    expect(find.textContaining('kg'), findsNothing);
  });

  testWidgets('shows edit and delete buttons when editable', (tester) async {
    await tester.pumpWidget(
      wrap(
        CardMeasurement(
          measurement: baseMeasurement,
          isEditable: true,
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('hides edit and delete buttons when not editable', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        CardMeasurement(
          measurement: baseMeasurement,
          isEditable: false,
          onEdit: () {},
          onDelete: () {},
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
        CardMeasurement(
          measurement: baseMeasurement,
          isEditable: true,
          onEdit: () => editTapped = true,
          onDelete: () {},
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
        CardMeasurement(
          measurement: baseMeasurement,
          isEditable: true,
          onEdit: () {},
          onDelete: () => deleteTapped = true,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(deleteTapped, isTrue);
  });

  testWidgets('displays a ChipMetric for each populated body measurement', (
    tester,
  ) async {
    final fullMeasurement = BodyMeasurement(
      id: 'bm-3',
      recordedAt: DateTime(2026, 3, 5),
      chest: 100.0,
      waist: 85.0,
      hips: 95.0,
      leftArm: 35.0,
      rightArm: 35.5,
      leftThigh: 55.0,
      rightThigh: 55.5,
      leftCalf: 38.0,
      rightCalf: 38.5,
    );

    await tester.pumpWidget(
      wrap(
        CardMeasurement(
          measurement: fullMeasurement,
          isEditable: true,
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );

    expect(find.text('Poitrine'), findsOneWidget);
    expect(find.text('100.0 cm'), findsOneWidget);
    expect(find.text('Taille'), findsOneWidget);
    expect(find.text('Hanches'), findsOneWidget);
    expect(find.text('Bras G'), findsOneWidget);
    expect(find.text('Bras D'), findsOneWidget);
    expect(find.text('Cuisse G'), findsOneWidget);
    expect(find.text('Cuisse D'), findsOneWidget);
    expect(find.text('Mollet G'), findsOneWidget);
    expect(find.text('Mollet D'), findsOneWidget);
  });

  testWidgets('does not display a ChipMetric for unset fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        CardMeasurement(
          measurement: baseMeasurement,
          isEditable: true,
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );

    expect(find.text('Poitrine'), findsNothing);
  });

  testWidgets('displays notes when present and non-empty', (tester) async {
    final withNotes = BodyMeasurement(
      id: 'bm-4',
      recordedAt: DateTime(2026, 3, 5),
      notes: 'Après entraînement',
    );

    await tester.pumpWidget(
      wrap(
        CardMeasurement(
          measurement: withNotes,
          isEditable: true,
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );

    expect(find.text('Après entraînement'), findsOneWidget);
  });

  testWidgets('does not display a notes block when notes are blank', (
    tester,
  ) async {
    final blankNotes = BodyMeasurement(
      id: 'bm-5',
      recordedAt: DateTime(2026, 3, 5),
      notes: '   ',
    );

    await tester.pumpWidget(
      wrap(
        CardMeasurement(
          measurement: blankNotes,
          isEditable: true,
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );

    expect(find.text('   '), findsNothing);
  });

  testWidgets('switches to a column layout on narrow widths', (tester) async {
    await tester.pumpWidget(
      wrap(
        CardMeasurement(
          measurement: baseMeasurement,
          isEditable: true,
          onEdit: () {},
          onDelete: () {},
        ),
        width: 300,
      ),
    );

    expect(find.text('05/03/2026'), findsOneWidget);
    expect(find.text('80.5 kg'), findsOneWidget);
  });
}
