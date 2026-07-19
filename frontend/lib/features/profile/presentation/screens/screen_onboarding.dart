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

  String? _selectedGender;
  String? _selectedObjective;
  String? _selectedBirthDate;
  bool _isLoading = false;

  bool get _isFormValid {
    return parseNullableText(_firstNameController.text) != null &&
        parseNullableText(_usernameController.text) != null &&
        parseDecimal(_heightController.text) != null &&
        _selectedBirthDate != null &&
        _selectedGender != null;
  }

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

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _selectedBirthDate = formatDateForApi(picked);
      _birthDateController.text = formatDate(picked);
    });
  }

  Future<void> _submit() async {
    if (_isLoading || !_isFormValid) {
      return;
    }

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

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(formatExceptionMessage(error)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Complète ton profil'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quelques infos pour personnaliser ton suivi. Tu pourras les modifier plus tard.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FormProfile(
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
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || !_isFormValid ? null : _submit,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  disabledForegroundColor: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continuer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
