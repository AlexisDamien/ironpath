import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/identity/presentation/providers/provider_identity.dart';
import '../../features/training/presentation/providers/provider_training.dart';
import '../../features/training/presentation/providers/provider_rest_timer.dart';
import '../../features/training/presentation/screens/screen_rest_timer.dart';
import '../widgets/component_email_verification_banner.dart';
import 'nav_bar.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  String _formatSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(providerTraining);
    final hasActiveSession = trainingState.activeSession != null;
    final stateIdentity = ref.watch(providerIdentity);
    final restTimerState = ref.watch(providerRestTimer);

    final location = GoRouterState.of(context).matchedLocation;
    final isOnSessionScreen = location == '/session';
    final currentIndex = switch (location) {
      '/dashboard' => 0,
      '/programs' => 1,
      '/session' => 2,
      '/bodymetrics' => 3,
      '/profile' => 4,
      _ => 0,
    };

    final showFab =
        hasActiveSession && (!isOnSessionScreen || restTimerState.isActive);

    String fabLabel;
    if (!restTimerState.isActive) {
      fabLabel = 'Session active';
    } else if (restTimerState.isOvertime) {
      fabLabel = 'Repos +${_formatSeconds(restTimerState.overtimeSeconds)}';
    } else {
      fabLabel = 'Repos ${_formatSeconds(restTimerState.remainingSeconds)}';
    }

    return Scaffold(
      body: Column(
        children: [
          if (!stateIdentity.isEmailVerified)
            const ComponentEmailVerificationBanner(),
          Expanded(child: child),
        ],
      ),
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: () {
                if (isOnSessionScreen && restTimerState.isActive) {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => const ScreenRestTimer(),
                    ),
                  );
                } else {
                  context.go('/session');
                }
              },
              icon: Icon(
                  restTimerState.isActive ? Icons.timer : Icons.fitness_center),
              label: Text(fabLabel),
              backgroundColor: Theme.of(context).colorScheme.primary,
            )
          : null,
      bottomNavigationBar: NavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
            case 1:
              context.go('/programs');
            case 2:
              context.go('/session');
            case 3:
              context.go('/bodymetrics');
            case 4:
              context.go('/profile');
          }
        },
      ),
    );
  }
}
