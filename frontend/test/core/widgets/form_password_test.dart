import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ironpath/core/widgets/form_password.dart';

Widget buildForm({
  required GlobalKey<FormState> formKey,
  required TextEditingController password,
  required TextEditingController confirmation,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: FormPassword(
            controller: password,
            confirmController: confirmation,
            autovalidateMode: AutovalidateMode.disabled,
          ),
        ),
      ),
    ),
  );
}

void main() {
  late TextEditingController password;
  late TextEditingController confirmation;
  late GlobalKey<FormState> formKey;

  setUp(() {
    password = TextEditingController();
    confirmation = TextEditingController();
    formKey = GlobalKey<FormState>();
  });

  tearDown(() {
    password.dispose();
    confirmation.dispose();
  });

  testWidgets('refuse un mot de passe vide', (tester) async {
    await tester.pumpWidget(
      buildForm(
        formKey: formKey,
        password: password,
        confirmation: confirmation,
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    expect(find.text('Le mot de passe est obligatoire'), findsOneWidget);
    expect(find.text('Confirmez le mot de passe'), findsOneWidget);
  });

  testWidgets('indique chaque règle manquante dans l’ordre', (tester) async {
    await tester.pumpWidget(
      buildForm(
        formKey: formKey,
        password: password,
        confirmation: confirmation,
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'abcdefghijk');
    confirmation.text = 'abcdefghijk';
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Utilisez au moins 12 caractères'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'abcdefghijkl',
    );
    confirmation.text = 'abcdefghijkl';
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Ajoutez au moins une majuscule'), findsOneWidget);
  });

  testWidgets('accepte un mot de passe fort confirmé', (tester) async {
    await tester.pumpWidget(
      buildForm(
        formKey: formKey,
        password: password,
        confirmation: confirmation,
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'MotDePasse12!',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'MotDePasse12!',
    );

    expect(formKey.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Très fort'), findsOneWidget);
    expect(find.text('5/5'), findsOneWidget);
  });

  testWidgets('refuse une confirmation différente', (tester) async {
    await tester.pumpWidget(
      buildForm(
        formKey: formKey,
        password: password,
        confirmation: confirmation,
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'MotDePasse12!',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'MotDePasse13!',
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(
      find.text('Les mots de passe ne correspondent pas'),
      findsOneWidget,
    );
  });

  testWidgets('permet d’afficher puis masquer le mot de passe', (tester) async {
    await tester.pumpWidget(
      buildForm(
        formKey: formKey,
        password: password,
        confirmation: confirmation,
      ),
    );

    final passwordField = find.byType(TextFormField).first;
    final editableText = find.descendant(
      of: passwordField,
      matching: find.byType(EditableText),
    );
    final visibilityButton = find.descendant(
      of: passwordField,
      matching: find.byType(IconButton),
    );

    expect(editableText, findsOneWidget);
    expect(visibilityButton, findsOneWidget);
    expect(
      tester.widget<EditableText>(editableText).obscureText,
      isTrue,
    );

    await tester.tap(visibilityButton);
    await tester.pump();

    expect(
      tester.widget<EditableText>(editableText).obscureText,
      isFalse,
    );
    expect(
      find.descendant(
        of: passwordField,
        matching: find.byTooltip('Masquer le mot de passe'),
      ),
      findsOneWidget,
    );
  });
}
