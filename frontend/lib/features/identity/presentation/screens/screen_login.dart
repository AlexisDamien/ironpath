import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/presentation/providers/provider_profile.dart';
import '../providers/provider_identity.dart';
import '../../domain/state_identity.dart';

class ScreenLogin extends ConsumerStatefulWidget {
  const ScreenLogin({super.key});

  @override
  ConsumerState<ScreenLogin> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<ScreenLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
      if (next.status == StatusAuth.authenticated) {
        ref.read(providerProfile.notifier).loadProfile();
        context.go('/dashboard');
      }
      if (next.status == StatusAuth.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
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
                  return null;
                },
              ),
              const SizedBox(height: 24),
              authState.status == StatusAuth.loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ref.read(providerIdentity.notifier).login(
                                _emailController.text,
                                _passwordController.text,
                              );
                        }
                      },
                      child: const Text('Se connecter'),
                    ),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Pas encore de compte ? S\'inscrire'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
