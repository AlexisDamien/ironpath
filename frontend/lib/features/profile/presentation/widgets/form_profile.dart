import 'package:flutter/material.dart';

class FormProfile extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController usernameController;
  final TextEditingController heightController;
  final TextEditingController birthDateController;
  final String? selectedGender;
  final String? selectedObjective;
  final bool showRequiredIndicators;
  final VoidCallback onPickBirthDate;
  final ValueChanged<String?> onGenderSelected;
  final ValueChanged<String?> onObjectiveSelected;
  final ValueChanged<String>? onFieldChanged;

  const FormProfile({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.usernameController,
    required this.heightController,
    required this.birthDateController,
    required this.selectedGender,
    required this.selectedObjective,
    required this.onPickBirthDate,
    required this.onGenderSelected,
    required this.onObjectiveSelected,
    this.showRequiredIndicators = false,
    this.onFieldChanged,
  });

  String _label(String label, {bool required = false}) {
    return showRequiredIndicators && required ? '$label *' : label;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: firstNameController,
          decoration: InputDecoration(
            labelText: _label('Prénom', required: true),
            prefixIcon: const Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: onFieldChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: lastNameController,
          decoration: InputDecoration(
            labelText: _label('Nom'),
            prefixIcon: const Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: onFieldChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            labelText: _label('Nom d\'utilisateur', required: true),
            prefixIcon: const Icon(Icons.alternate_email),
          ),
          onChanged: onFieldChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: heightController,
          decoration: InputDecoration(
            labelText: _label('Taille (cm)', required: true),
            prefixIcon: const Icon(Icons.height),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onFieldChanged,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onPickBirthDate,
          child: AbsorbPointer(
            child: TextField(
              controller: birthDateController,
              decoration: InputDecoration(
                labelText: _label('Date de naissance', required: true),
                prefixIcon: const Icon(Icons.cake_outlined),
                hintText: 'Sélectionner une date',
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        DropdownMenu<String>(
          initialSelection:
              const ['MALE', 'FEMALE', 'OTHER'].contains(selectedGender)
                  ? selectedGender
                  : null,
          label: Text(_label('Genre', required: true)),
          leadingIcon: const Icon(Icons.person_outline),
          expandedInsets: EdgeInsets.zero,
          onSelected: onGenderSelected,
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: 'MALE', label: 'Homme'),
            DropdownMenuEntry(value: 'FEMALE', label: 'Femme'),
            DropdownMenuEntry(value: 'OTHER', label: 'Autre'),
          ],
        ),
        const SizedBox(height: 16),
        DropdownMenu<String>(
          initialSelection: const [
            'MUSCLE_GAIN',
            'WEIGHT_LOSS',
            'MAINTENANCE',
            'ENDURANCE',
            'STRENGTH',
          ].contains(selectedObjective)
              ? selectedObjective
              : null,
          label: const Text('Objectif'),
          leadingIcon: const Icon(Icons.flag_outlined),
          expandedInsets: EdgeInsets.zero,
          onSelected: onObjectiveSelected,
          dropdownMenuEntries: const [
            DropdownMenuEntry(
              value: 'MUSCLE_GAIN',
              label: 'Prise de masse',
            ),
            DropdownMenuEntry(
              value: 'WEIGHT_LOSS',
              label: 'Perte de poids',
            ),
            DropdownMenuEntry(
              value: 'MAINTENANCE',
              label: 'Maintien',
            ),
            DropdownMenuEntry(
              value: 'ENDURANCE',
              label: 'Endurance',
            ),
            DropdownMenuEntry(
              value: 'STRENGTH',
              label: 'Force',
            ),
          ],
        ),
      ],
    );
  }
}
