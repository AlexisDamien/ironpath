import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/profile.dart';
import '../providers/provider_profile.dart';

class ScreenEditProfile extends ConsumerStatefulWidget {
  final Profile? profile;

  const ScreenEditProfile({
    super.key,
    this.profile,
  });

  @override
  ConsumerState<ScreenEditProfile> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<ScreenEditProfile> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _heightController = TextEditingController();
  final _birthDateController = TextEditingController();

  String? _selectedGender;
  String? _selectedObjective;
  String? _selectedBirthDate;

  bool _isLoading = false;

  bool get _isCreating => widget.profile == null;

  @override
  void initState() {
    super.initState();

    final profile = widget.profile;

    if (profile == null) {
      return;
    }

    _firstNameController.text = profile.firstName ?? '';
    _lastNameController.text = profile.lastName ?? '';
    _usernameController.text = profile.username ?? '';
    _heightController.text = profile.height?.toString() ?? '';

    _selectedGender = profile.gender;
    _selectedObjective = profile.objective;
    _selectedBirthDate = profile.birthDate;

    _birthDateController.text = profile.birthDate ?? '';
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

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profile = Profile(
        // null lorsqu'il s'agit d'une création.
        id: widget.profile?.id,
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

      if (!mounted) {
        return;
      }

      // true indique à ScreenProfile qu'il faut recharger.
      Navigator.of(context).pop(true);
    } catch (exception) {
      if (!mounted) {
        return;
      }

      final message = exception.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickBirthDate() async {
    final parsedDate = _selectedBirthDate == null
        ? null
        : DateTime.tryParse(_selectedBirthDate!);

    final picked = await showDatePicker(
      context: context,
      initialDate: parsedDate ?? DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );

    if (picked == null || !mounted) {
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          _isCreating ? 'Créer le profil' : 'Modifier le profil',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Sauvegarder',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Prénom',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
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
                labelText: 'Nom d\'utilisateur',
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Taille (cm)',
                prefixIcon: Icon(Icons.height),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickBirthDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: _birthDateController,
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance',
                    prefixIcon: Icon(Icons.cake_outlined),
                    hintText: 'Sélectionner une date',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownMenu<String>(
              initialSelection: [
                'MALE',
                'FEMALE',
                'OTHER',
              ].contains(_selectedGender)
                  ? _selectedGender
                  : null,
              label: const Text('Genre'),
              leadingIcon: const Icon(Icons.person_outline),
              expandedInsets: EdgeInsets.zero,
              onSelected: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              dropdownMenuEntries: const [
                DropdownMenuEntry(
                  value: 'MALE',
                  label: 'Homme',
                ),
                DropdownMenuEntry(
                  value: 'FEMALE',
                  label: 'Femme',
                ),
                DropdownMenuEntry(
                  value: 'OTHER',
                  label: 'Autre',
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownMenu<String>(
              initialSelection: [
                'MUSCLE_GAIN',
                'WEIGHT_LOSS',
                'MAINTENANCE',
                'ENDURANCE',
                'STRENGTH',
              ].contains(_selectedObjective)
                  ? _selectedObjective
                  : null,
              label: const Text('Objectif'),
              leadingIcon: const Icon(Icons.flag_outlined),
              expandedInsets: EdgeInsets.zero,
              onSelected: (value) {
                setState(() {
                  _selectedObjective = value;
                });
              },
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
