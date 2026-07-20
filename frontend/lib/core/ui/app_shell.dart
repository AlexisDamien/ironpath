import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/identity/presentation/providers/provider_identity.dart';
import '../../features/training/presentation/providers/provider_training.dart';
import '../../features/training/presentation/providers/provider_rest_timer.dart';
import '../../features/training/presentation/screens/screen_rest_timer.dart';
import '../utils/format_duration.dart';
import '../widgets/component_email_verification_banner.dart';
import 'nav_bar.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(providerTraining);
    final hasActiveSession = trainingState.activeSession != null;
    final stateIdentity = ref.watch(providerIdentity);
    final restTimerState = ref.watch(providerRestTimer);

    final isOnSessionScreen = navigationShell.currentIndex == 2;

    final showFab =
        hasActiveSession && (!isOnSessionScreen || restTimerState.isActive);

    String fabLabel;
    if (!restTimerState.isActive) {
      fabLabel = 'Session active';
    } else if (restTimerState.isOvertime) {
      fabLabel =
          'Repos +${formatClockDuration(restTimerState.overtimeSeconds)}';
    } else {
      fabLabel =
          'Repos ${formatClockDuration(restTimerState.remainingSeconds)}';
    }

    return Scaffold(
      body: Column(
        children: [
          if (!stateIdentity.isEmailVerified)
            const SafeArea(
              bottom: false,
              child: ComponentEmailVerificationBanner(),
            ),
          Expanded(child: navigationShell),
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
                  navigationShell.goBranch(2);
                }
              },
              icon: Icon(
                restTimerState.isActive ? Icons.timer : Icons.fitness_center,
              ),
              label: Text(fabLabel),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            )
          : null,
      bottomNavigationBar: NavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
