import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ironpath/core/ui/app_theme.dart';

class IronNavBar extends StatelessWidget {
  const IronNavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const List<_IronNavDestination> _destinations = [
    _IronNavDestination(icon: Icons.home_outlined,  label: 'Accueil'),
    _IronNavDestination(icon: Icons.fitness_center,  label: 'Entraîner'),
    _IronNavDestination(icon: Icons.show_chart,      label: 'Progrès'),
    _IronNavDestination(icon: Icons.person_outline,  label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navBackground = isDark ? IronColors.darkSurface : IronColors.lightSurface;
    final borderColor   = isDark ? IronColors.darkBorder  : IronColors.lightBorder;
    final activeColor   = colorScheme.primary;
    final inactiveColor = isDark
        ? const Color(0xFF555550)
        : const Color(0xFFB0AAA2);

    return Semantics(
      label: 'Navigation principale',
      child: Container(
        decoration: BoxDecoration(
          color: navBackground,
          border: Border(
            top: BorderSide(color: borderColor, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_destinations.length, (index) {
                return Expanded(
                  child: _IronNavItem(
                    destination:   _destinations[index],
                    isActive:      index == currentIndex,
                    activeColor:   activeColor,
                    inactiveColor: inactiveColor,
                    onTap: () => onDestinationSelected(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _IronNavItem extends StatelessWidget {
  const _IronNavItem({
    required this.destination,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final _IronNavDestination destination;
  final bool         isActive;
  final Color        activeColor;
  final Color        inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itemColor = isActive ? activeColor : inactiveColor;

    return Semantics(
      label:    destination.label,
      selected: isActive,
      button:   true,
      child: GestureDetector(
        onTap:     onTap,
        behavior:  HitTestBehavior.opaque,
        child: SizedBox(
          height: IronSpacing.minTapTarget + 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration:  const Duration(milliseconds: 200),
                curve:     Curves.easeOut,
                height:    3,
                width:     isActive ? 28 : 0,
                margin:    const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color:        isActive ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              Icon(destination.icon, color: itemColor, size: 24),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize:   10,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  color:      itemColor,
                ),
                child: Text(destination.label),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _IronNavDestination {
  const _IronNavDestination({required this.icon, required this.label});
  final IconData icon;
  final String   label;
}
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const List<String> _routes = [
    '/home',
    '/training',
    '/progress',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _routes
        .indexWhere((route) => location.startsWith(route))
        .clamp(0, 3);

    return Scaffold(
      body: child,
      bottomNavigationBar: IronNavBar(
        currentIndex: currentIndex,
        onDestinationSelected: (index) => context.go(_routes[index]),
      ),
    );
  }
}