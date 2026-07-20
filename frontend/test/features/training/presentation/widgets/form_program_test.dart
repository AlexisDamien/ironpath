import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ironpath/features/training/presentation/widgets/form_program.dart';

void main() {
  late TextEditingController name;
  late TextEditingController description;
  late GlobalKey<FormState> formKey;

  setUp(() {
    name = TextEditingController();
    description = TextEditingController();
    formKey = GlobalKey<FormState>();
  });

  tearDown(() {
    name.dispose();
    description.dispose();
  });

  Widget app() => MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: FormProgram(
              nameController: name,
              descriptionController: description,
            ),
          ),
        ),
      );

  testWidgets('refuse un nom vide', (tester) async {
    await tester.pumpWidget(app());

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Le nom est requis'), findsOneWidget);
  });

  testWidgets('refuse un nom trop court', (tester) async {
    name.text = 'A';
    await tester.pumpWidget(app());

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(
      find.text('Le nom doit contenir au moins 2 caractères'),
      findsOneWidget,
    );
  });

  testWidgets('accepte un nom valide et une description vide', (tester) async {
    name.text = 'Push';
    await tester.pumpWidget(app());

    expect(formKey.currentState!.validate(), isTrue);
  });
}
