import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/training/presentation/providers/training_provider.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Programmes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Progrès',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(trainingProvider);
    final hasActiveSession = trainingState.activeSession != null;

    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = switch (location) {
      '/home' => 0,
      '/progress' => 1,
      '/profile' => 2,
      _ => 0,
    };

    return Scaffold(
      body: Stack(
        children: [
          child,
          if (hasActiveSession)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/session'),
                icon: const Icon(Icons.fitness_center),
                label: const Text('Session active'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/progress');
            case 2:
              context.go('/profile');
          }
        },
      ),
    );
  }
}