import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/constants/legal_texts.dart';
import '../../../../core/providers/provider_enums.dart';
import '../../../identity/presentation/providers/provider_identity.dart';
import '../widgets/card_settings_section.dart';
import '../widgets/popup_delete_account.dart';
import 'screen_change_password.dart';
import 'screen_legal.dart';

class ScreenSettings extends ConsumerWidget {
  const ScreenSettings({super.key});

  void _openLegalScreen(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ScreenLegal(
          title: title,
          content: content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitSystem = ref.watch(providerUnitSystem);
    final errorColor = Theme.of(context).colorScheme.error;

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
          CardSettingsSection(
            title: 'Compte',
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outlined),
                title: const Text('Modifier le mot de passe'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => const ScreenChangePassword(),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_forever_outlined,
                  color: errorColor,
                ),
                title: Text(
                  'Supprimer le compte',
                  style: TextStyle(color: errorColor),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => showDeleteAccountDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CardSettingsSection(
            title: 'Préférences',
            children: [
              const ListTile(
                leading: Icon(Icons.notifications_outlined),
                title: Text('Notifications'),
                trailing: _WipLabel(),
              ),
              const ListTile(
                leading: Icon(Icons.dark_mode_outlined),
                title: Text('Thème'),
                trailing: _WipLabel(),
              ),
              const ListTile(
                leading: Icon(Icons.language_outlined),
                title: Text('Langue'),
                trailing: _WipLabel(),
              ),
              ListTile(
                leading: const Icon(Icons.straighten_outlined),
                title: const Text('Unité de mesure'),
                trailing: DropdownButton<UnitSystem>(
                  value: unitSystem,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: UnitSystem.metric,
                      child: Text('cm / kg'),
                    ),
                    DropdownMenuItem(
                      value: UnitSystem.imperial,
                      child: Text('in / lbs'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(providerUnitSystem.notifier).state = value;
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const CardSettingsSection(
            title: 'Données',
            children: [
              ListTile(
                leading: Icon(Icons.download_outlined),
                title: Text('Exporter mes données'),
                trailing: _WipLabel(),
              ),
              ListTile(
                leading: Icon(Icons.watch_outlined),
                title: Text('Balance connectée'),
                trailing: _WipLabel(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const CardSettingsSection(
            title: 'Application',
            children: [
              ListTile(
                leading: Icon(Icons.info_outlined),
                title: Text('Version'),
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ListTile(
                leading: Icon(Icons.update_outlined),
                title: Text('Notes de version'),
                trailing: _WipLabel(),
              ),
              ListTile(
                leading: Icon(Icons.bug_report_outlined),
                title: Text('Signaler un bug'),
                trailing: _WipLabel(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CardSettingsSection(
            title: 'Légal',
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Politique de confidentialité'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _openLegalScreen(
                  context,
                  title: 'Politique de confidentialité',
                  content: LegalTexts.rgpd,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Conditions d\'utilisation'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _openLegalScreen(
                  context,
                  title: 'Conditions d\'utilisation',
                  content: LegalTexts.cgu,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CardSettingsSection(
            title: 'Session',
            children: [
              ListTile(
                leading: Icon(Icons.logout, color: errorColor),
                title: Text(
                  'Se déconnecter',
                  style: TextStyle(color: errorColor),
                ),
                onTap: () async {
                  await ref.read(providerIdentity.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _WipLabel extends StatelessWidget {
  const _WipLabel();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'WIP',
      style: TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
    );
  }
}
