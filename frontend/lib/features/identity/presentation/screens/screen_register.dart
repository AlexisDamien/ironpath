import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/legal_texts.dart';
import '../../../../core/widgets/form_password.dart';
import '../providers/provider_identity.dart';
import '../../domain/state_identity.dart';

class ScreenRegister extends ConsumerStatefulWidget {
  const ScreenRegister({super.key});

  @override
  ConsumerState<ScreenRegister> createState() => _ScreenRegisterState();
}

class _ScreenRegisterState extends ConsumerState<ScreenRegister> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _acceptCGU = false;
  bool _acceptRGPD = false;
  bool _showLegalError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showLegalScreen(BuildContext context, String title, String content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(title),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Fermer',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Text(
                content,
                style: const TextStyle(fontSize: 14, height: 1.8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final legalAccepted = _acceptCGU && _acceptRGPD;
    setState(() => _showLegalError = !legalAccepted);

    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || !legalAccepted) return;

    FocusScope.of(context).unfocus();
    ref.read(providerIdentity.notifier).register(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  Widget _buildConsentSection({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String consentText,
    required String linkText,
    required String legalTitle,
    required String legalContent,
  }) {
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: value,
            onChanged: onChanged,
            title: Text(consentText),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: TextButton.icon(
              onPressed: () =>
                  _showLegalScreen(context, legalTitle, legalContent),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(linkText),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(providerIdentity);
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(providerIdentity, (previous, next) {
      if (next.status == StatusAuth.authenticated &&
          previous?.status == StatusAuth.loading) {
        context.go('/onboarding');
      }
      if (next.status == StatusAuth.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline),
                const SizedBox(width: 8),
                Expanded(child: Text(next.errorMessage!)),
              ],
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: const Text('Créer un compte'),
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
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse email *',
                    helperText:
                        'Utilisée pour vérifier et récupérer votre compte',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
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
                const SizedBox(height: 16),
                FormPassword(
                  controller: _passwordController,
                  confirmController: _confirmPasswordController,
                  label: 'Mot de passe *',
                  confirmLabel: 'Confirmer le mot de passe *',
                ),
                const SizedBox(height: 16),
                _buildConsentSection(
                  value: _acceptCGU,
                  onChanged: (value) => setState(() {
                    _acceptCGU = value ?? false;
                    if (_acceptCGU && _acceptRGPD) {
                      _showLegalError = false;
                    }
                  }),
                  consentText:
                      'J’ai lu et j’accepte les Conditions Générales d’Utilisation.',
                  linkText: 'Lire les Conditions Générales d’Utilisation',
                  legalTitle: 'Conditions Générales d’Utilisation',
                  legalContent: LegalTexts.cgu,
                ),
                const SizedBox(height: 8),
                _buildConsentSection(
                  value: _acceptRGPD,
                  onChanged: (value) => setState(() {
                    _acceptRGPD = value ?? false;
                    if (_acceptCGU && _acceptRGPD) {
                      _showLegalError = false;
                    }
                  }),
                  consentText:
                      'J’accepte le traitement de mes données personnelles de santé conformément à la politique de confidentialité.',
                  linkText: 'Lire la politique de confidentialité',
                  legalTitle: 'Politique de confidentialité',
                  legalContent: LegalTexts.rgpd,
                ),
                if (_showLegalError) ...[
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
                            'Vous devez accepter les deux documents pour créer votre compte.',
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
                const SizedBox(height: 16),
                Text(
                  'Les champs marqués d’un * sont obligatoires.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: authState.status == StatusAuth.loading
                      ? Center(
                          child: Semantics(
                            label: 'Création du compte en cours',
                            child: const CircularProgressIndicator(),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Créer mon compte'),
                        ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Déjà un compte ? Se connecter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
