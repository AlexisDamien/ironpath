import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';
import '../../domain/models/profile.dart';
import '../../domain/profile_state.dart';
import '../../../bodymetrics/presentation/providers/bodymetrics_provider.dart';
import '../../../identity/presentation/providers/identity_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileProvider.notifier).loadProfile();
      ref.read(bodyMetricsProvider.notifier).loadMeasurements();
      ref.read(bodyMetricsProvider.notifier).loadCompositions();
    });
  }

  void _showSettingsSheet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final bodyMetricsState = ref.watch(bodyMetricsProvider);

    final lastComposition = bodyMetricsState.compositions.isNotEmpty
        ? bodyMetricsState.compositions.first
        : null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsSheet(context),
          ),
        ],
      ),
      body: profileState.status == ProfileStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : profileState.status == ProfileStatus.error
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        profileState.errorMessage ?? 'Une erreur est survenue',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(profileProvider.notifier).loadProfile(),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildProfileCard(context, profileState.profile),
                    const SizedBox(height: 16),
                    if (lastComposition != null)
                      _buildStatsCard(context, lastComposition),
                  ],
                ),
    );
  }

  Widget _buildProfileCard(BuildContext context, Profile? profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditProfileSheet(context, profile!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                profile != null
                    ? '${profile.firstName ?? ''} ${profile.lastName ?? ''}'
                            .trim()
                            .isEmpty
                        ? profile.username ?? 'Utilisateur'
                        : '${profile.firstName ?? ''} ${profile.lastName ?? ''}'
                            .trim()
                    : 'Utilisateur',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (profile?.username != null) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '@${profile!.username}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
            const Divider(height: 32),
            if (profile != null) ...[
              _buildInfoRow(Icons.cake_outlined, 'Date de naissance',
                  profile.birthDate ?? 'Non renseigné'),
              const SizedBox(height: 12),
              _buildInfoRow(
                  Icons.height,
                  'Taille',
                  profile.height != null
                      ? '${profile.height} cm'
                      : 'Non renseigné'),
              const SizedBox(height: 12),
              _buildInfoRow(
                  Icons.person_outline, 'Genre', _formatGender(profile.gender)),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.flag_outlined, 'Objectif',
                  _formatObjective(profile.objective)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, dynamic lastComposition) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques corporelles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (lastComposition.bmi != null)
                  Expanded(
                    child: _buildStatItem(
                      context,
                      lastComposition.bmi!.toStringAsFixed(1),
                      'IMC',
                    ),
                  ),
                if (lastComposition.bmr != null)
                  Expanded(
                    child: _buildStatItem(
                      context,
                      '${lastComposition.bmr}',
                      'BMR (kcal)',
                    ),
                  ),
                if (lastComposition.metabolicAge != null)
                  Expanded(
                    child: _buildStatItem(
                      context,
                      '${lastComposition.metabolicAge} ans',
                      'Âge métabo.',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  String _formatGender(String? gender) {
    return switch (gender) {
      'MALE' => 'Homme',
      'FEMALE' => 'Femme',
      'OTHER' => 'Autre',
      _ => 'Non renseigné',
    };
  }

  String _formatObjective(String? objective) {
    return switch (objective) {
      'MUSCLE_GAIN' => 'Prise de masse',
      'WEIGHT_LOSS' => 'Perte de poids',
      'MAINTENANCE' => 'Maintien',
      'ENDURANCE' => 'Endurance',
      'STRENGTH' => 'Force',
      _ => 'Non renseigné',
    };
  }

  void _showEditProfileSheet(BuildContext context, Profile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _EditProfileScreen(profile: profile),
      ),
    );
  }
}

class _EditProfileScreen extends ConsumerStatefulWidget {
  final Profile profile;

  const _EditProfileScreen({required this.profile});

  @override
  ConsumerState<_EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<_EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _heightController = TextEditingController();
  String? _selectedGender;
  String? _selectedObjective;
  String? _selectedBirthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.profile.firstName ?? '';
    _lastNameController.text = widget.profile.lastName ?? '';
    _usernameController.text = widget.profile.username ?? '';
    _heightController.text = widget.profile.height?.toString() ?? '';
    _selectedGender = widget.profile.gender;
    _selectedObjective = widget.profile.objective;
    _selectedBirthDate = widget.profile.birthDate;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final updatedProfile = Profile(
        id: widget.profile.id,
        firstName: _firstNameController.text.trim().isEmpty
            ? null
            : _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
        username: _usernameController.text.trim().isEmpty
            ? null
            : _usernameController.text.trim(),
        height: double.tryParse(_heightController.text),
        gender: _selectedGender,
        objective: _selectedObjective,
        birthDate: _selectedBirthDate,
      );
      await ref.read(profileProvider.notifier).updateProfile(updatedProfile);
      if (mounted) Navigator.of(context).pop();
    } catch (exception) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exception.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate != null
          ? DateTime.parse(_selectedBirthDate!)
          : DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked.toIso8601String().split('T').first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Modifier le profil',
          style: TextStyle(fontWeight: FontWeight.bold),
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickBirthDate,
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Date de naissance',
                    prefixIcon: const Icon(Icons.cake_outlined),
                    hintText: _selectedBirthDate ?? 'Sélectionner une date',
                  ),
                  controller:
                      TextEditingController(text: _selectedBirthDate ?? ''),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownMenu<String>(
              initialSelection:
                  ['MALE', 'FEMALE', 'OTHER'].contains(_selectedGender)
                      ? _selectedGender
                      : null,
              label: const Text('Genre'),
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
              initialSelection: [
                'MUSCLE_GAIN',
                'WEIGHT_LOSS',
                'MAINTENANCE',
                'ENDURANCE',
                'STRENGTH'
              ].contains(_selectedObjective)
                  ? _selectedObjective
                  : null,
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
          ],
        ),
      ),
    );
  }
}

class _SettingsScreen extends ConsumerWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Paramètres',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Compte',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outlined),
                  title: const Text('Modifier le mot de passe'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showChangePasswordDialog(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Supprimer le compte',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showDeleteAccountDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Préférences',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  trailing: const Text(
                    'WIP',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Thème'),
                  trailing: const Text(
                    'WIP',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: const Text('Langue'),
                  trailing: const Text(
                    'WIP',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Données',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Exporter mes données'),
                  trailing: const Text(
                    'WIP',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.watch_outlined),
                  title: const Text('Balance connectée'),
                  trailing: const Text(
                    'WIP',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Application',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outlined),
                  title: const Text('Version'),
                  trailing: const Text(
                    '1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.update_outlined),
                  title: const Text('Notes de version'),
                  trailing: const Text(
                    'WIP',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text('Signaler un bug'),
                  trailing: const Text(
                    'WIP',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Légal',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Politique de confidentialité'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Conditions d\'utilisation'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Session',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Se déconnecter',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () async {
                await ref.read(identityProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier le mot de passe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => isLoading = true);
                      try {
                        await ref
                            .read(identityProvider.notifier)
                            .changePassword(
                              currentPassword: currentPasswordController.text,
                              newPassword: newPasswordController.text,
                            );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mot de passe modifié avec succès'),
                            ),
                          );
                        }
                      } catch (exception) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(exception.toString()),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    bool isLoading = false;
    bool confirmed = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Supprimer le compte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cette action est irréversible. Toutes vos données seront supprimées.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: confirmed,
                onChanged: (value) =>
                    setState(() => confirmed = value ?? false),
                title: const Text(
                  'Je comprends que cette action est irréversible',
                  style: TextStyle(fontSize: 13),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isLoading || !confirmed
                  ? null
                  : () async {
                      setState(() => isLoading = true);
                      try {
                        await ref.read(identityProvider.notifier).deleteAccount(
                              password: passwordController.text,
                            );
                        if (context.mounted) {
                          context.go('/login');
                        }
                      } catch (exception) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(exception.toString()),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Supprimer'),
            ),
          ],
        ),
      ),
    );
  }
}
