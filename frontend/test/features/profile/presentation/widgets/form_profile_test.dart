import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ironpath/features/profile/presentation/widgets/form_profile.dart';

class _Controllers {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final username = TextEditingController();
  final height = TextEditingController();
  final birthDate = TextEditingController();

  void dispose() {
    firstName.dispose();
    lastName.dispose();
    username.dispose();
    height.dispose();
    birthDate.dispose();
  }
}

Widget _buildForm(
  _Controllers controllers,
  GlobalKey<FormState> key, {
  bool required = true,
  VoidCallback? onPickBirthDate,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: key,
          child: FormProfile(
            firstNameController: controllers.firstName,
            lastNameController: controllers.lastName,
            usernameController: controllers.username,
            heightController: controllers.height,
            birthDateController: controllers.birthDate,
            selectedGender: null,
            selectedObjective: null,
            showRequiredIndicators: required,
            autovalidateMode: AutovalidateMode.disabled,
            onPickBirthDate: onPickBirthDate ?? () {},
            onGenderSelected: (_) {},
            onObjectiveSelected: (_) {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  late _Controllers controllers;
  late GlobalKey<FormState> formKey;

  setUp(() {
    controllers = _Controllers();
    formKey = GlobalKey<FormState>();
  });

  tearDown(() => controllers.dispose());

  testWidgets('affiche les astérisques uniquement sur les champs requis',
      (tester) async {
    await tester.pumpWidget(_buildForm(controllers, formKey));

    expect(find.text('Prénom *'), findsOneWidget);
    expect(find.text('Nom'), findsOneWidget);
    expect(find.text('Nom d’utilisateur *'), findsOneWidget);
    expect(find.text('Taille (cm) *'), findsOneWidget);
    expect(find.text('Date de naissance *'), findsOneWidget);
    expect(find.text('Genre *'), findsOneWidget);
    expect(find.text('Objectif'), findsOneWidget);
    expect(find.text('Entre 3 et 30 caractères'), findsOneWidget);
  });

  testWidgets('valide les champs obligatoires', (tester) async {
    await tester.pumpWidget(_buildForm(controllers, formKey));

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    expect(find.text('Renseignez votre prénom'), findsOneWidget);
    expect(find.text('Renseignez votre nom d’utilisateur'), findsOneWidget);
    expect(find.text('Renseignez votre taille'), findsOneWidget);
    expect(find.text('Sélectionnez votre date de naissance'), findsOneWidget);
  });

  testWidgets('valide la longueur du nom d’utilisateur', (tester) async {
    controllers.firstName.text = 'Alex';
    controllers.height.text = '178';
    controllers.birthDate.text = '03/02/1990';
    controllers.username.text = 'ab';

    await tester.pumpWidget(_buildForm(controllers, formKey));

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(
      find.text(
        'Le nom d’utilisateur doit contenir entre 3 et 30 caractères',
      ),
      findsOneWidget,
    );
  });

  testWidgets('accepte une taille décimale avec virgule', (tester) async {
    controllers.firstName.text = 'Alex';
    controllers.username.text = 'alex';
    controllers.height.text = '178,5';
    controllers.birthDate.text = '03/02/1990';

    await tester.pumpWidget(_buildForm(controllers, formKey));

    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('refuse une taille nulle ou non numérique', (tester) async {
    controllers.firstName.text = 'Alex';
    controllers.username.text = 'alex';
    controllers.height.text = '0';
    controllers.birthDate.text = '03/02/1990';

    await tester.pumpWidget(_buildForm(controllers, formKey));

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(
      find.text('Saisissez une taille valide supérieure à 0'),
      findsOneWidget,
    );
  });

  testWidgets('le champ date déclenche le sélecteur', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _buildForm(
        controllers,
        formKey,
        onPickBirthDate: () => tapped = true,
      ),
    );

    final dateField = find.widgetWithText(
      TextFormField,
      'Date de naissance *',
    );
    expect(dateField, findsOneWidget);

    await tester.ensureVisible(dateField);
    await tester.pumpAndSettle();
    await tester.tap(dateField);

    expect(tapped, isTrue);
  });
}
