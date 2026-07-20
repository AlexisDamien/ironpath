import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/format_exception.dart';
import '../../../../core/widgets/form_password.dart';
import '../../../identity/presentation/providers/provider_identity.dart';

class ScreenChangePassword extends ConsumerStatefulWidget {
  const ScreenChangePassword({super.key});

  @override
  ConsumerState<ScreenChangePassword> createState() =>
      _ScreenChangePasswordState();
}

class _ScreenChangePasswordState extends ConsumerState<ScreenChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrent = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final messenger = ScaffoldMessenger.of(context);
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      await ref.read(providerIdentity.notifier).changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );
      if (mounted) {
        Navigator.of(context).pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('Mot de passe modifié avec succès.')),
        );
      }
    } catch (exception) {
      if (!mounted) return;

      final message = formatExceptionMessage(exception);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
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
        title: const Text(
          'Modifier le mot de passe',
          style: TextStyle(fontWeight: FontWeight.bold),
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
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tous les champs sont obligatoires.'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe actuel *',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrent
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      tooltip: _obscureCurrent
                          ? 'Afficher le mot de passe actuel'
                          : 'Masquer le mot de passe actuel',
                      onPressed: () => setState(
                        () => _obscureCurrent = !_obscureCurrent,
                      ),
                    ),
                  ),
                  obscureText: _obscureCurrent,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Saisissez votre mot de passe actuel';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FormPassword(
                  controller: _newPasswordController,
                  confirmController: _confirmPasswordController,
                  label: 'Nouveau mot de passe *',
                  confirmLabel: 'Confirmer le nouveau mot de passe *',
                ),
                const SizedBox(height: 112),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _submit,
            icon: _isLoading
                ? Semantics(
                    label: 'Enregistrement en cours',
                    child: const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              _isLoading
                  ? 'Enregistrement…'
                  : 'Enregistrer le mot de passe',
            ),
          ),
        ),
      ),
    );
  }
}
