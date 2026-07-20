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
              : 'Email pas encore vérifié — vérifiez votre boîte mail.',
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
        const SnackBar(content: Text('Email de vérification renvoyé.')),
      );
    } catch (exception) {
      if (!mounted) return;
      final message = formatExceptionMessage(exception);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onErrorContainer;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: [
        TextButton(
          onPressed: (_isResending || _cooldownSeconds > 0) ? null : _resend,
          style: TextButton.styleFrom(foregroundColor: foreground),
          child: _isResending
              ? Semantics(
                  label: 'Renvoi de l’email en cours',
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  ),
                )
              : Text(
                  _cooldownSeconds > 0
                      ? 'Renvoyer dans ${_cooldownSeconds}s'
                      : 'Renvoyer',
                ),
        ),
        TextButton(
          onPressed: _isChecking ? null : _checkStatus,
          style: TextButton.styleFrom(foregroundColor: foreground),
          child: _isChecking
              ? Semantics(
                  label: 'Vérification en cours',
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  ),
                )
              : const Text('J’ai vérifié'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;

    return SafeArea(
      bottom: false,
      child: Semantics(
        container: true,
        liveRegion: true,
        label:
            'Avertissement. Votre adresse email doit être vérifiée pour débloquer toutes les fonctionnalités.',
        child: Container(
          width: double.infinity,
          color: colorScheme.errorContainer,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stackActions =
                  constraints.maxWidth < 560 || textScale > 1.3;
              final message = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: colorScheme.onErrorContainer,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vérifiez votre email pour débloquer toutes les fonctionnalités.',
                      style: TextStyle(
                        color: colorScheme.onErrorContainer,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              );

              if (stackActions) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    message,
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildActionButtons(context),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: message),
                  const SizedBox(width: 8),
                  _buildActionButtons(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
