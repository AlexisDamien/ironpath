import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/format_date.dart';
import '../../../../core/utils/format_exception.dart';
import '../../../../core/utils/parse_input.dart';
import '../../domain/models/profile_input.dart';
import '../providers/provider_profile.dart';
import '../widgets/form_profile.dart';

class ScreenOnboarding extends ConsumerStatefulWidget {
  const ScreenOnboarding({super.key});

  @override
  ConsumerState<ScreenOnboarding> createState() => _ScreenOnboardingState();
}

class _ScreenOnboardingState extends ConsumerState<ScreenOnboarding> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _heightController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedGender;
  String? _selectedObjective;
  String? _selectedBirthDate;
  bool _isLoading = false;
  bool _showValidationErrors = false;

  List<String> get _validationMessages {
    final messages = <String>[];
    if (parseNullableText(_firstNameController.text) == null) {
      messages.add('Renseignez votre prénom.');
    }
    final username = parseNullableText(_usernameController.text);
    if (username == null) {
      messages.add('Renseignez votre nom d’utilisateur.');
    } else if (username.length < 3 || username.length > 30) {
      messages.add(
        'Le nom d’utilisateur doit contenir entre 3 et 30 caractères.',
      );
    }
    final height = parseDecimal(_heightController.text);
    if (height == null || height <= 0) {
      messages.add('Renseignez une taille valide en centimètres.');
    }
    if (_selectedBirthDate == null) {
      messages.add('Sélectionnez votre date de naissance.');
    }
    if (_selectedGender == null) {
      messages.add('Sélectionnez votre genre.');
    }
    return messages;
  }

  bool get _isFormValid => _validationMessages.isEmpty;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _heightController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _selectedBirthDate = formatDateForApi(picked);
      _birthDateController.text = formatDate(picked);
    });
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    setState(() => _showValidationErrors = true);
    final fieldsValid = _formKey.currentState?.validate() ?? false;
    if (!fieldsValid || !_isFormValid) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final input = ProfileInput(
        firstName: parseNullableText(_firstNameController.text),
        lastName: parseNullableText(_lastNameController.text),
        username: parseNullableText(_usernameController.text),
        height: parseDecimal(_heightController.text),
        gender: _selectedGender,
        objective: _selectedObjective,
        birthDate: _selectedBirthDate,
      );

      await ref.read(providerProfile.notifier).updateProfile(input);

      if (mounted) context.go('/dashboard');
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline),
              const SizedBox(width: 8),
              Expanded(child: Text(formatExceptionMessage(error))),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final validationMessages = _validationMessages;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: const Text('Complétez votre profil'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quelques informations pour personnaliser votre suivi. Vous pourrez les modifier plus tard.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: FormProfile(
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                  usernameController: _usernameController,
                  heightController: _heightController,
                  birthDateController: _birthDateController,
                  selectedGender: _selectedGender,
                  selectedObjective: _selectedObjective,
                  showRequiredIndicators: true,
                  onFieldChanged: (_) => setState(() {}),
                  onPickBirthDate: _pickBirthDate,
                  onGenderSelected: (value) {
                    setState(() => _selectedGender = value);
                  },
                  onObjectiveSelected: (value) {
                    setState(() => _selectedObjective = value);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Les champs marqués d’un * sont obligatoires.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              if (_showValidationErrors && validationMessages.isNotEmpty) ...[
                const SizedBox(height: 20),
                Semantics(
                  liveRegion: true,
                  container: true,
                  label: 'Le formulaire contient des erreurs',
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.error),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline, color: colorScheme.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Complétez les champs suivants :',
                                style: TextStyle(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (final message in validationMessages)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('• $message'),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? Semantics(
                    label: 'Enregistrement du profil en cours',
                    child: const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                      : const Text('Continuer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
