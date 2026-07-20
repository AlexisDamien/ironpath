import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/screens/screen_dashboard.dart';
import '../../features/identity/domain/state_identity.dart';
import '../../features/identity/presentation/providers/provider_identity.dart';
import '../../features/identity/presentation/screens/screen_login.dart';
import '../../features/identity/presentation/screens/screen_register.dart';
import '../../features/profile/domain/state_profile.dart';
import '../../features/profile/presentation/providers/provider_profile.dart';
import '../../features/profile/presentation/screens/screen_onboarding.dart';
import '../../features/training/presentation/screens/screen_programs.dart';
import '../../features/training/presentation/screens/screen_sessions.dart';
import '../../features/bodymetrics/presentation/screens/screen_bodymetrics.dart';
import '../../features/profile/presentation/screens/screen_profile.dart';
import '../ui/app_shell.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(providerIdentity, (_, __) => notifyListeners());
    ref.listen(providerProfile, (_, __) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: refreshNotifier,
    redirect: (context, routerState) {
      final stateIdentity = ref.read(providerIdentity);
      final stateProfile = ref.read(providerProfile);

      final isAuthenticated = stateIdentity.status == StatusAuth.authenticated;
      final isAuthRoute = routerState.matchedLocation == '/login' ||
          routerState.matchedLocation == '/register';
      final isOnboardingRoute = routerState.matchedLocation == '/onboarding';

      if (!isAuthenticated) {
        return isAuthRoute ? null : '/login';
      }

      if (isAuthRoute) return '/dashboard';

      final profileLoaded = stateProfile.status == StatusProfile.success;
      final profileComplete = stateProfile.profile?.isProfileComplete ?? false;

      if (profileLoaded && !profileComplete && !isOnboardingRoute) {
        return '/onboarding';
      }

      if (profileLoaded && profileComplete && isOnboardingRoute) {
        return '/dashboard';
      }

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
        path: '/onboarding',
        builder: (context, routerState) => const ScreenOnboarding(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, routerState, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, routerState) => const ScreenDashboard(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/programs',
                builder: (context, routerState) => const ScreenPrograms(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/session',
                builder: (context, routerState) => const ScreenSessions(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bodymetrics',
                builder: (context, routerState) => const ScreenBodyMetrics(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, routerState) => const ScreenProfile(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
