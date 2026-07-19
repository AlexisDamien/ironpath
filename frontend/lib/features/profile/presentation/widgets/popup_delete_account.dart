import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/format_exception.dart';
import 'package:go_router/go_router.dart';
import '../../../identity/presentation/providers/provider_identity.dart';

void showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
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
              onChanged: (value) => setState(() => confirmed = value ?? false),
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
                      await ref.read(providerIdentity.notifier).deleteAccount(
                            password: passwordController.text,
                          );
                      if (context.mounted) {
                        context.go('/login');
                      }
                    } catch (exception) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(formatExceptionMessage(exception)),
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
