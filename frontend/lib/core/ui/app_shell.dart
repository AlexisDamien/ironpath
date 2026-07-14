import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/training/presentation/providers/provider_training.dart';
import '../../features/training/presentation/widgets/sheet_start_session.dart';
import 'nav_bar.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(providerTraining);
    final hasActiveSession = trainingState.activeSession != null;

    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = switch (location) {
      '/dashboard' => 0,
      '/programs' => 1,
      '/bodymetrics' => 3,
      '/profile' => 4,
      _ => 0,
    };

    return Scaffold(
      body: child,
      floatingActionButton: hasActiveSession
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/session'),
              icon: const Icon(Icons.fitness_center),
              label: const Text('Session active'),
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
              _startSession(context);
            case 3:
              context.go('/bodymetrics');
            case 4:
              context.go('/profile');
          }
        },
      ),
    );
  }

  void _startSession(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => const SheetStartSession(),
    );
  }
}
