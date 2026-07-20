import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/state_identity.dart';
import '../providers/provider_identity.dart';
import '../widgets/popup_forgot_password.dart';

class ScreenLogin extends ConsumerStatefulWidget {
  const ScreenLogin({super.key});

  @override
  ConsumerState<ScreenLogin> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends ConsumerState<ScreenLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    ref.read(providerIdentity.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
          rememberMe: _rememberMe,
        );
  }

  void _restorePasswordFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _passwordFocusNode.requestFocus();
      _passwordController.selection = TextSelection.collapsed(
        offset: _passwordController.text.length,
      );
    });
  }

  Future<void> _forgotPassword() async {
    final sent = await showForgotPasswordDialog(
      context,
      ref,
      initialEmail: _emailController.text.trim(),
    );

    if (!mounted || !sent) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.mark_email_read_outlined),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Si un compte correspond à cette adresse, un email de '
                'réinitialisation vient d’être envoyé.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context, {double size = 132}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = isDark
        ? 'assets/branding/ironpath_logo_dark.png'
        : 'assets/branding/ironpath_logo_light.png';

    return Semantics(
      image: true,
      label: 'Logo IronPath',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              asset,
              width: size,
              height: size,
              fit: BoxFit.contain,
              gaplessPlayback: true,
            ),
            const SizedBox(height: 8),
            Text(
              'IRONPATH',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.2,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionRestoration(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogo(context, size: 152),
        const SizedBox(height: 32),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Semantics(
          liveRegion: true,
          child: const Text('Restauration de votre session…'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(providerIdentity);
    final isLoading = authState.status == StatusAuth.loading;

    ref.listen(providerIdentity, (previous, next) {
      if (next.status == StatusAuth.authenticated &&
          previous?.status != StatusAuth.authenticated) {
        TextInput.finishAutofillContext();
        context.go('/dashboard');
      }

      final hasNewError = next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage;
      if (hasNewError) {
        final messenger = ScaffoldMessenger.of(context);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
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
        _restorePasswordFocus();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight > 48.0
                      ? constraints.maxHeight - 48.0
                      : 0.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: authState.isRestoringSession
                        ? _buildSessionRestoration(context)
                        : AutofillGroup(
                            child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildLogo(context),
                                  const SizedBox(height: 28),
                                  Semantics(
                                    header: true,
                                    child: Text(
                                      'Connexion',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Retrouvez vos programmes et poursuivez '
                                    'votre entraînement.',
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tous les champs sont obligatoires.',
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 28),
                                  TextFormField(
                                    controller: _emailController,
                                    readOnly: isLoading,
                                    decoration: const InputDecoration(
                                      labelText: 'Adresse email *',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.email],
                                    onChanged: (_) => ref
                                        .read(providerIdentity.notifier)
                                        .clearError(),
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
                                  TextFormField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    readOnly: isLoading,
                                    decoration: InputDecoration(
                                      labelText: 'Mot de passe *',
                                      prefixIcon:
                                          const Icon(Icons.lock_outlined),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        tooltip: _obscurePassword
                                            ? 'Afficher le mot de passe'
                                            : 'Masquer le mot de passe',
                                        onPressed: isLoading
                                            ? null
                                            : () => setState(
                                                  () => _obscurePassword =
                                                      !_obscurePassword,
                                                ),
                                      ),
                                    ),
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    onChanged: (_) => ref
                                        .read(providerIdentity.notifier)
                                        .clearError(),
                                    onFieldSubmitted: (_) {
                                      if (!isLoading) _submit();
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Saisissez votre mot de passe';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  CheckboxListTile(
                                    value: _rememberMe,
                                    onChanged: isLoading
                                        ? null
                                        : (value) => setState(
                                              () => _rememberMe = value ?? true,
                                            ),
                                    title: const Text('Se souvenir de moi'),
                                    subtitle: const Text(
                                      'Conserver la connexion après la fermeture '
                                      'de l’application.',
                                    ),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed:
                                          isLoading ? null : _forgotPassword,
                                      icon: const Icon(
                                        Icons.key_outlined,
                                        size: 20,
                                      ),
                                      label: const Text(
                                        'Mot de passe oublié ?',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (isLoading)
                                    Center(
                                      child: Semantics(
                                        label: 'Connexion en cours',
                                        child:
                                            const CircularProgressIndicator(),
                                      ),
                                    )
                                  else
                                    ElevatedButton.icon(
                                      onPressed: _submit,
                                      icon: const Icon(Icons.login),
                                      label: const Text('Se connecter'),
                                    ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () => context.go('/register'),
                                    child: const Text(
                                      'Pas encore de compte ? S’inscrire',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
