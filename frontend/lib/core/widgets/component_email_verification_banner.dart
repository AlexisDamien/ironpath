import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/format_exception.dart';
import '../../features/identity/presentation/providers/provider_identity.dart';

class ComponentEmailVerificationBanner extends ConsumerStatefulWidget {
  const ComponentEmailVerificationBanner({super.key});

  @override
  ConsumerState<ComponentEmailVerificationBanner> createState() =>
      _ComponentEmailVerificationBannerState();
}

class _ComponentEmailVerificationBannerState
    extends ConsumerState<ComponentEmailVerificationBanner> {
  bool _isChecking = false;
  bool _isResending = false;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds -= 1);
      }
    });
  }

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    await ref.read(providerIdentity.notifier).refreshEmailVerificationStatus();
    if (!mounted) return;
    setState(() => _isChecking = false);

    final isVerified = ref.read(providerIdentity).isEmailVerified;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isVerified
              ? 'Email vérifié !'
              : 'Email pas encore vérifié — vérifie ta boîte mail',
        ),
      ),
    );
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      await ref.read(providerIdentity.notifier).resendVerificationEmail();
      if (!mounted) return;
      _startCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email de vérification renvoyé')),
      );
    } catch (exception) {
      if (!mounted) return;
      final message = formatExceptionMessage(exception);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_outlined,
            color: Theme.of(context).colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Vérifie ton email pour débloquer toutes les fonctionnalités',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: (_isResending || _cooldownSeconds > 0) ? null : _resend,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            child: _isResending
                ? SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  )
                : Text(
                    _cooldownSeconds > 0
                        ? 'Renvoyer (${_cooldownSeconds}s)'
                        : 'Renvoyer',
                    style: const TextStyle(fontSize: 12),
                  ),
          ),
          TextButton(
            onPressed: _isChecking ? null : _checkStatus,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            child: _isChecking
                ? SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  )
                : const Text("J'ai vérifié", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
