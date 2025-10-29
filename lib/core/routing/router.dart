import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import '../../features/auth/presentation/pages/log_in.dart';
import '../../features/auth/presentation/pages/register.dart';
import '../../features/auth/presentation/provider/auth_provider.dart';
import '../../features/booking/domain/models/consultation.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/booking/presentation/pages/checkout_page.dart';
import '../../features/consult/domain/models/doctor.dart';
import '../../features/consult/presentation/pages/consult_page.dart';
import '../../features/health/presentation/pages/health_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/help_support_page.dart';
import '../../features/profile/presentation/pages/privacy_policy_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/terms_of_service_page.dart';
import '../../features/subscription/domain/entities/subscription_plan.dart';
import '../../features/subscription/pages/checkout_page.dart' as sub_checkout;
import '../../features/subscription/pages/subscription_page.dart';
import '../../features/subscription/pages/subscription_plan.dart';
import '../../features/video_call/domain/models/call_state.dart';
import '../../features/video_call/presentation/pages/video_call_page.dart';
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
    final location = state.matchedLocation;

    // Allow splash screen to handle its own logic
    if (location == '/splash') return null;

    // If not logged in and not on auth pages, redirect to login
    if (!isLoggedIn && location != '/login' && location != '/register') {
      return '/login';
    }

    // If logged in and on auth pages, redirect to home
    if (isLoggedIn && (location == '/login' || location == '/register')) {
      return '/home';
    }

    // Otherwise, allow the navigation
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

      // Video Call Route (outside shell - no bottom navigation)
      GoRoute(
        path: '/video-call',
        builder: (context, state) {
          final callInfo = state.extra as VideoCallInfo;
          return VideoCallPage(callInfo: callInfo);
        },
      ),

      // Booking Route (outside shell - no bottom navigation)
      GoRoute(
        path: '/booking',
        builder: (context, state) {
          final doctor = state.extra as Doctor;
          return BookingPage(doctor: doctor);
        },
        routes: [
          GoRoute(
            path: 'checkout',
            builder: (context, state) {
              final consultation = state.extra as Consultation;
              return CheckoutPage(consultation: consultation);
            },
          ),
        ],
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
                routes: [
                  GoRoute(
                    path: 'subscription',
                    builder: (context, state) => const SubscriptionStatusPage(),
                    routes: [
                      GoRoute(
                        path: 'plans',
                        builder: (context, state) =>
                            const SubscriptionPlansPage(),
                        routes: [
                          GoRoute(
                            path: 'checkout',
                            builder: (context, state) {
                              final plan = state.extra as SubscriptionPlan;
                              return sub_checkout.SubscriptionCheckoutPage(
                                plan: plan,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsPage(),
                  ),
                  GoRoute(
                    path: 'privacy-policy',
                    builder: (context, state) => const PrivacyPolicyPage(),
                  ),
                  GoRoute(
                    path: 'terms-of-service',
                    builder: (context, state) => const TermsOfServicePage(),
                  ),
                  GoRoute(
                    path: 'help-support',
                    builder: (context, state) => const HelpSupportPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
