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
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center_outlined),
          activeIcon: Icon(Icons.fitness_center),
          label: 'Programmes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: 'Session',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Mesures',
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
      '/dashboard' => 0,
      '/programs' => 1,
      '/bodymetrics' => 3,
      '/profile' => 4,
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
              context.go('/dashboard');
            case 1:
              context.go('/programs');
            case 2:
              _startSession(context, ref);
            case 3:
              context.go('/bodymetrics');
            case 4:
              context.go('/profile');
          }
        },
      ),
    );
  }

  void _startSession(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _StartSessionSheet(),
    );
  }
}

class _StartSessionSheet extends ConsumerWidget {
  const _StartSessionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(trainingProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Démarrer une session',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await ref.read(trainingProvider.notifier).startSession(
                      name: 'Session libre',
                    );
                if (context.mounted) context.push('/session');
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Session libre'),
            ),
          ),
          const SizedBox(height: 12),
          if (trainingState.programs.isNotEmpty) ...[
            const Text(
              'Depuis un programme',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            ...trainingState.programs.map(
              (program) => ListTile(
                title: Text(program.name),
                subtitle: Text(
                  '${program.exercises.length} exercice${program.exercises.length > 1 ? 's' : ''}',
                ),
                trailing: const Icon(Icons.play_arrow),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(trainingProvider.notifier).startSession(
                        programId: program.id,
                        name: program.name,
                      );
                  if (context.mounted) context.push('/session');
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
