import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ironpath/features/profile/presentation/screens/screen_change_password.dart';
import '../../../identity/presentation/providers/provider_identity.dart';
import '../widgets/popup_delete_account.dart';
import '../../../../core/templates/legal_texts.dart';

void _showLegalScreen(BuildContext context, String title, String content) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.8),
          ),
        ),
      ),
    ),
  );
}

class ScreenSettings extends ConsumerWidget {
  const ScreenSettings({super.key});

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
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => const ScreenChangePassword(),
                    ),
                  ),
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
                  onTap: () => showDeleteAccountDialog(context, ref),
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
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications_outlined),
                  title: Text('Notifications'),
                  trailing: Text(
                    'WIP',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.dark_mode_outlined),
                  title: Text('Thème'),
                  trailing: Text(
                    'WIP',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.language_outlined),
                  title: Text('Langue'),
                  trailing: Text(
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
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.download_outlined),
                  title: Text('Exporter mes données'),
                  trailing: Text(
                    'WIP',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.watch_outlined),
                  title: Text('Balance connectée'),
                  trailing: Text(
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
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outlined),
                  title: Text('Version'),
                  trailing: Text(
                    '1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.update_outlined),
                  title: Text('Notes de version'),
                  trailing: Text(
                    'WIP',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.bug_report_outlined),
                  title: Text('Signaler un bug'),
                  trailing: Text(
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
                  onTap: () => _showLegalScreen(
                    context,
                    'Politique de confidentialité',
                    LegalTexts.rgpd,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Conditions d\'utilisation'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showLegalScreen(
                    context,
                    'Conditions d\'utilisation',
                    LegalTexts.cgu,
                  ),
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
                await ref.read(providerIdentity.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
