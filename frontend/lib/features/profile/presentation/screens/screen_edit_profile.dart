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
    if (_isLoading) {
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
                    child: CircularProgressIndicator(strokeWidth: 2),
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
        child: FormProfile(
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          usernameController: _usernameController,
          heightController: _heightController,
          birthDateController: _birthDateController,
          selectedGender: _selectedGender,
          selectedObjective: _selectedObjective,
          onPickBirthDate: _pickBirthDate,
          onGenderSelected: (value) {
            setState(() => _selectedGender = value);
          },
          onObjectiveSelected: (value) {
            setState(() => _selectedObjective = value);
          },
        ),
      ),
    );
  }
}
