import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sly_killer_template/core/network/auth/auth_state/auth_session_controller.dart';

import '../core/network/auth/auth_state/auth_session.dart';

/// Placeholder screens (template only).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Splash')));
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Login')));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Home')));
}

/// Routes (template constants)
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
}

/// Forces GoRouter to re-check redirects when auth session changes.
class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(this.ref) {
    ref.listen<AuthSession>(
      authSessionControllerProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref ref;
}

/// Router provider (single source of truth)
final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _GoRouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    redirect: (context, state) {
      final session = ref.read(authSessionControllerProvider);
      final isAuthed = session.isAuthenticated;

      final loc = state.matchedLocation;
      final goingToLogin = loc == AppRoutes.login;
      final goingToSplash = loc == AppRoutes.splash;

      // While session is "unknown", we use Splash as the neutral page.
      // In this template, hydrate() runs immediately; Splash is safe default.
      // If you want a dedicated "unknown" state later, add it to AuthSession.
      if (!isAuthed) {
        if (goingToLogin || goingToSplash) return null;
        return AppRoutes.login;
      }

      if (goingToLogin || goingToSplash) return AppRoutes.home;

      return null;
    },
  );
});
