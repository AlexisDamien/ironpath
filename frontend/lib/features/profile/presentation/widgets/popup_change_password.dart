import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/component_modal_header.dart';
import '../../../identity/presentation/providers/provider_identity.dart';

void showChangePasswordDialog(BuildContext context, WidgetRef ref) {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  bool isLoading = false;
  final messenger = ScaffoldMessenger.of(context);

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 12, 8, 0),
        title: const ComponentModalHeader(title: 'Modifier le mot de passe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                ),
                obscureText: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        try {
                          await ref
                              .read(providerIdentity.notifier)
                              .changePassword(
                                currentPassword: currentPasswordController.text,
                                newPassword: newPasswordController.text,
                              );
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Mot de passe modifié avec succès',
                                ),
                              ),
                            );
                          }
                        } catch (exception) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text(exception.toString())),
                            );
                          }
                        } finally {
                          if (dialogContext.mounted) {
                            setState(() => isLoading = false);
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer le mot de passe'),
              ),
            ],
          ),
        ),
      ),
    ),
  ).whenComplete(() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
  });
}
