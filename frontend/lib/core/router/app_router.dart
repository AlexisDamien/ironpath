import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/screens/screen_dashboard.dart';
import '../../features/identity/domain/state_identity.dart';
import '../../features/identity/presentation/providers/provider_identity.dart';
import '../../features/identity/presentation/screens/screen_login.dart';
import '../../features/identity/presentation/screens/screen_register.dart';
import '../../features/training/presentation/screens/screen_programs.dart';
import '../../features/training/presentation/screens/screen_active_session.dart';
import '../../features/bodymetrics/presentation/screens/screen_bodymetrics.dart';
import '../../features/profile/presentation/screens/screen_profile.dart';
import '../ui/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final stateIdentity = ref.watch(providerIdentity);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, routerState) {
      final isAuthenticated = stateIdentity.status == StatusAuth.authenticated ||
          stateIdentity.status == StatusAuth.error;
      final isAuthRoute = routerState.matchedLocation == '/login' ||
          routerState.matchedLocation == '/register';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, routerState) => const ScreenLogin(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, routerState) => const ScreenRegister(),
      ),
      GoRoute(
        path: '/session',
        builder: (context, routerState) => const ScreenActiveSession(),
      ),
      ShellRoute(
        builder: (context, routerState, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, routerState) => const ScreenDashboard(),
          ),
          GoRoute(
            path: '/programs',
            builder: (context, routerState) => const ScreenPrograms(),
          ),
          GoRoute(
            path: '/bodymetrics',
            builder: (context, routerState) => const ScreenBodyMetrics(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, routerState) => const ScreenProfile(),
          ),
        ],
      ),
    ],
  );
});
