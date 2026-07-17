import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/profile.dart';
import '../providers/provider_profile.dart';

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

    final formattedDate = picked.toIso8601String().split('T').first;

    setState(() {
      _selectedBirthDate = formattedDate;
      _birthDateController.text = formattedDate;
    });
  }

  String? _nullableText(String value) {
    final trimmedValue = value.trim();
    return trimmedValue.isEmpty ? null : trimmedValue;
  }

  bool get _isFormValid {
    final height = double.tryParse(
      _heightController.text.trim().replaceAll(',', '.'),
    );
    return _nullableText(_firstNameController.text) != null &&
        _nullableText(_usernameController.text) != null &&
        height != null &&
        _selectedBirthDate != null &&
        _selectedGender != null;
  }

  Future<void> _submit() async {
    if (_isLoading || !_isFormValid) return;

    setState(() => _isLoading = true);

    try {
      final profile = Profile(
        id: null,
        firstName: _nullableText(_firstNameController.text),
        lastName: _nullableText(_lastNameController.text),
        username: _nullableText(_usernameController.text),
        height: double.tryParse(
          _heightController.text.trim().replaceAll(',', '.'),
        ),
        gender: _selectedGender,
        objective: _selectedObjective,
        birthDate: _selectedBirthDate,
      );

      await ref.read(providerProfile.notifier).updateProfile(profile);

      if (!mounted) return;

      context.go('/dashboard');
    } catch (exception) {
      if (!mounted) return;

      final message = exception.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Prénom *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur *',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Taille (cm) *',
                prefixIcon: Icon(Icons.height),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickBirthDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: _birthDateController,
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance *',
                    prefixIcon: Icon(Icons.cake_outlined),
                    hintText: 'Sélectionner une date',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownMenu<String>(
              initialSelection: _selectedGender,
              label: const Text('Genre *'),
              leadingIcon: const Icon(Icons.person_outline),
              expandedInsets: EdgeInsets.zero,
              onSelected: (value) => setState(() => _selectedGender = value),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'MALE', label: 'Homme'),
                DropdownMenuEntry(value: 'FEMALE', label: 'Femme'),
                DropdownMenuEntry(value: 'OTHER', label: 'Autre'),
              ],
            ),
            const SizedBox(height: 16),
            DropdownMenu<String>(
              initialSelection: _selectedObjective,
              label: const Text('Objectif'),
              leadingIcon: const Icon(Icons.flag_outlined),
              expandedInsets: EdgeInsets.zero,
              onSelected: (value) => setState(() => _selectedObjective = value),
              dropdownMenuEntries: const [
                DropdownMenuEntry(
                    value: 'MUSCLE_GAIN', label: 'Prise de masse'),
                DropdownMenuEntry(
                    value: 'WEIGHT_LOSS', label: 'Perte de poids'),
                DropdownMenuEntry(value: 'MAINTENANCE', label: 'Maintien'),
                DropdownMenuEntry(value: 'ENDURANCE', label: 'Endurance'),
                DropdownMenuEntry(value: 'STRENGTH', label: 'Force'),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isLoading || !_isFormValid) ? null : _submit,
                style: ElevatedButton.styleFrom(
                    disabledBackgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    disabledForegroundColor: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.5)),
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
