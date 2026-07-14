import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/provider_identity.dart';
import '../../domain/state_identity.dart';

class ScreenRegister extends ConsumerStatefulWidget {
  const ScreenRegister({super.key});

  @override
  ConsumerState<ScreenRegister> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<ScreenRegister> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rgpdConsent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(providerIdentity);

    ref.listen(providerIdentity, (previous, next) {
      if (next.status == StatusAuth.unauthenticated &&
          previous?.status == StatusAuth.loading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé ! Vérifiez votre email.'),
          ),
        );
        context.go('/login');
      }
      if (next.status == StatusAuth.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email obligatoire';
                  }
                  if (!value.contains('@')) {
                    return 'Format email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mot de passe obligatoire';
                  }
                  if (value.length < 8) {
                    return 'Minimum 8 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _rgpdConsent,
                    onChanged: (value) {
                      setState(() {
                        _rgpdConsent = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'J\'accepte les conditions générales et le traitement de mes données personnelles (RGPD)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              authState.status == StatusAuth.loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _rgpdConsent
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                ref.read(providerIdentity.notifier).register(
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                              }
                            }
                          : null,
                      child: const Text('S\'inscrire'),
                    ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Déjà un compte ? Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
