import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/component_modal_header.dart';
import '../providers/provider_identity.dart';

Future<bool> showForgotPasswordDialog(
  BuildContext context,
  WidgetRef ref, {
  String initialEmail = '',
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _ForgotPasswordDialog(
      ref: ref,
      initialEmail: initialEmail,
    ),
  );

  return result ?? false;
}

class _ForgotPasswordDialog extends StatefulWidget {
  final WidgetRef ref;
  final String initialEmail;

  const _ForgotPasswordDialog({
    required this.ref,
    required this.initialEmail,
  });

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _close() {
    if (_isLoading) return;
    Navigator.of(context).pop(false);
  }

  Future<void> _submit() async {
    if (_isLoading || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.ref.read(providerIdentity.notifier).requestPasswordReset(
            email: _emailController.text.trim(),
          );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 12, 8, 0),
        title: ComponentModalHeader(
          title: 'Mot de passe oublié',
          onClose: _close,
          closeEnabled: !_isLoading,
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Saisissez votre adresse email. Si un compte correspond, '
                    'vous recevrez un lien pour choisir un nouveau mot de passe.',
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    autofocus: true,
                    readOnly: _isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Adresse email *',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                    onFieldSubmitted: (_) {
                      if (!_isLoading) _submit();
                    },
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) {
                        return 'Saisissez votre adresse email';
                      }
                      if (!email.contains('@')) {
                        return 'Saisissez une adresse email valide';
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Semantics(
                      liveRegion: true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(
                      _isLoading
                          ? 'Envoi en cours…'
                          : 'Envoyer le lien de réinitialisation',
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
