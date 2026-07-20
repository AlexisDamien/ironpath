import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/format_date.dart';
import '../../../../core/utils/format_exception.dart';
import '../../../../core/utils/parse_input.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/profile_input.dart';
import '../providers/provider_profile.dart';
import '../widgets/form_profile.dart';

class ScreenEditProfile extends ConsumerStatefulWidget {
  final Profile? profile;

  const ScreenEditProfile({
    super.key,
    this.profile,
  });

  @override
  ConsumerState<ScreenEditProfile> createState() => _ScreenEditProfileState();
}

class _ScreenEditProfileState extends ConsumerState<ScreenEditProfile> {
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
    _birthDateController.text = formatApiDate(
      profile.birthDate,
      fallback: '',
    );
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
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez votre genre.')),
      );
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
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formatExceptionMessage(error),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

    setState(() {
      _selectedBirthDate = formatDateForApi(picked);
      _birthDateController.text = formatDate(picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          _isCreating ? 'Créer le profil' : 'Modifier le profil',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Annuler et fermer',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _submit,
            icon: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              _isLoading
                  ? 'Enregistrement…'
                  : _isCreating
                      ? 'Créer le profil'
                      : 'Enregistrer les modifications',
            ),
          ),
        ),
      ),
    );
  }
}
