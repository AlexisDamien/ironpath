import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/format_exception.dart';
import '../../../../core/widgets/component_modal_header.dart';
import '../../../identity/presentation/providers/provider_identity.dart';

Future<bool> showDeleteAccountDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DeleteAccountDialog(ref: ref),
  );

  return result ?? false;
}

class _DeleteAccountDialog extends StatefulWidget {
  final WidgetRef ref;

  const _DeleteAccountDialog({required this.ref});

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _confirmed = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _close() {
    if (_isLoading) return;
    Navigator.of(context).pop(false);
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || !_confirmed) {
      setState(() {
        _errorMessage = !_confirmed
            ? 'Confirmez que vous comprenez le caractère irréversible de la suppression.'
            : null;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.ref.read(providerIdentity.notifier).deleteAccount(
            password: _passwordController.text,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = formatExceptionMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_isLoading,
      child: AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 12, 8, 0),
        title: ComponentModalHeader(
          title: 'Supprimer le compte',
          onClose: _close,
          closeEnabled: !_isLoading,
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Cette action est irréversible. Toutes vos données seront supprimées.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tous les champs sont obligatoires.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    readOnly: _isLoading,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe actuel *',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        tooltip: _obscurePassword
                            ? 'Afficher le mot de passe'
                            : 'Masquer le mot de passe',
                        onPressed: _isLoading
                            ? null
                            : () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Saisissez votre mot de passe actuel';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _confirmed,
                    onChanged: _isLoading
                        ? null
                        : (value) => setState(() {
                              _confirmed = value ?? false;
                              if (_confirmed) _errorMessage = null;
                            }),
                    title: const Text(
                      'Je comprends que cette action est irréversible *',
                      style: TextStyle(fontSize: 13),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Semantics(
                      liveRegion: true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_forever_outlined),
                    label: Text(
                      _isLoading
                          ? 'Suppression en cours…'
                          : 'Supprimer définitivement le compte',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
