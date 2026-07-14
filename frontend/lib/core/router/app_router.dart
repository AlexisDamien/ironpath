import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/identity/domain/identity_state.dart';
import '../../features/identity/presentation/providers/identity_provider.dart';
import '../../features/identity/presentation/screens/login_screen.dart';
import '../../features/identity/presentation/screens/register_screen.dart';
import '../../features/training/presentation/screens/programs_screen.dart';
import '../../features/training/presentation/screens/active_session_screen.dart';
import '../../features/bodymetrics/presentation/screens/bodymetrics_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../ui/nav_bar.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final identityState = ref.watch(identityProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, routerState) {
      final isAuthenticated = identityState.status == AuthStatus.authenticated;
      final isAuthRoute = routerState.matchedLocation == '/login' ||
          routerState.matchedLocation == '/register';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, routerState) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, routerState) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/session',
        builder: (context, routerState) => const ActiveSessionScreen(),
      ),
      ShellRoute(
        builder: (context, routerState, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, routerState) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/programs',
            builder: (context, routerState) => const ProgramsScreen(),
          ),
          GoRoute(
            path: '/bodymetrics',
            builder: (context, routerState) => const BodyMetricsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, routerState) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
