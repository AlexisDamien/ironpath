import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormProfile extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController usernameController;
  final TextEditingController heightController;
  final TextEditingController birthDateController;
  final String? selectedGender;
  final String? selectedObjective;
  final bool showRequiredIndicators;
  final AutovalidateMode autovalidateMode;
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
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.onFieldChanged,
  });

  String _label(String label, {bool required = false}) {
    return showRequiredIndicators && required ? '$label *' : label;
  }

  String? _validateFirstName(String? value) {
    final text = value?.trim() ?? '';
    if (showRequiredIndicators && text.isEmpty) {
      return 'Renseignez votre prénom';
    }
    if (text.length > 50) {
      return 'Le prénom ne peut pas dépasser 50 caractères';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    final text = value?.trim() ?? '';
    if (text.length > 50) {
      return 'Le nom ne peut pas dépasser 50 caractères';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    final text = value?.trim() ?? '';
    if (showRequiredIndicators && text.isEmpty) {
      return 'Renseignez votre nom d’utilisateur';
    }
    if (text.isNotEmpty && (text.length < 3 || text.length > 30)) {
      return 'Le nom d’utilisateur doit contenir entre 3 et 30 caractères';
    }
    return null;
  }

  String? _validateHeight(String? value) {
    final text = value?.trim().replaceAll(',', '.') ?? '';
    if (showRequiredIndicators && text.isEmpty) {
      return 'Renseignez votre taille';
    }
    if (text.isNotEmpty) {
      final height = double.tryParse(text);
      if (height == null || height <= 0) {
        return 'Saisissez une taille valide supérieure à 0';
      }
    }
    return null;
  }

  String? _validateBirthDate(String? value) {
    if (showRequiredIndicators && (value == null || value.trim().isEmpty)) {
      return 'Sélectionnez votre date de naissance';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: firstNameController,
          decoration: InputDecoration(
            labelText: _label('Prénom', required: true),
            prefixIcon: const Icon(Icons.person_outline),
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(50)],
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autovalidateMode: autovalidateMode,
          validator: _validateFirstName,
          onChanged: onFieldChanged,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: lastNameController,
          decoration: InputDecoration(
            labelText: _label('Nom'),
            prefixIcon: const Icon(Icons.person_outline),
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(50)],
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autovalidateMode: autovalidateMode,
          validator: _validateLastName,
          onChanged: onFieldChanged,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: usernameController,
          decoration: InputDecoration(
            labelText: _label('Nom d’utilisateur', required: true),
            helperText: 'Entre 3 et 30 caractères',
            prefixIcon: const Icon(Icons.alternate_email),
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(30)],
          textInputAction: TextInputAction.next,
          autovalidateMode: autovalidateMode,
          validator: _validateUsername,
          onChanged: onFieldChanged,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: heightController,
          decoration: InputDecoration(
            labelText: _label('Taille (cm)', required: true),
            prefixIcon: const Icon(Icons.height),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
          ],
          textInputAction: TextInputAction.next,
          autovalidateMode: autovalidateMode,
          validator: _validateHeight,
          onChanged: onFieldChanged,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: birthDateController,
          readOnly: true,
          showCursor: false,
          onTap: onPickBirthDate,
          decoration: InputDecoration(
            labelText: _label('Date de naissance', required: true),
            prefixIcon: const Icon(Icons.cake_outlined),
            suffixIcon: const Icon(Icons.calendar_today_outlined),
            hintText: 'Sélectionner une date',
          ),
          autovalidateMode: autovalidateMode,
          validator: _validateBirthDate,
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
