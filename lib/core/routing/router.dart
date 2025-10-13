import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import '../../features/auth/presentation/pages/log_in.dart';
import '../../features/auth/presentation/pages/register.dart';
import '../../features/auth/presentation/provider/auth_provider.dart';
import '../../features/consult/presentation/pages/consult_page.dart';
import '../../features/health/presentation/pages/health_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/widgets/splash_screen.dart';
import '../widgets/patient_shell.dart';

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh() {
    Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => notifyListeners(),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // watch to rebuild provider when auth state changes (safety), although refreshListenable handles route refreshes
  ref.watch(authStateProvider);

  String? redirect(BuildContext context, GoRouterState state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final isAuthRoute =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';
    final isSplash = state.matchedLocation == '/splash';

    if (isSplash) return null; // allow splash to decide

    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }
    if (isLoggedIn && isAuthRoute) {
      return '/home';
    }
    return null;
  }

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthRefresh(),
    redirect: redirect,
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Patient Shell with 5 tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            PatientShell(navigationShell: navigationShell),
        branches: [
          // Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // Consult
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/consult',
                builder: (context, state) => const ConsultPage(),
              ),
            ],
          ),
          // AI Assistant
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ai',
                builder: (context, state) => const AIAssistantPage(),
              ),
            ],
          ),
          // Health
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/health',
                builder: (context, state) => const HealthPage(),
              ),
            ],
          ),
          // Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
