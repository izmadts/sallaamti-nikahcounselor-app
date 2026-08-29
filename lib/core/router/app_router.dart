import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/application/presentation/application_screen.dart';
import '../../features/apply/presentation/apply_screen.dart';
import '../../features/auth/presentation/language_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/browse/presentation/browse_screen.dart';
import '../../features/browse/presentation/candidate_detail_screen.dart';
import '../../features/client_profile/presentation/walk_in_wizard_screen.dart';
import '../../features/clients/presentation/client_create_screen.dart';
import '../../features/clients/presentation/client_detail_screen.dart';
import '../../features/clients/presentation/client_list_screen.dart';
import '../../features/commission/presentation/commission_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/guide/presentation/guide_screen.dart';
import '../../features/interests/presentation/interests_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/performance/presentation/performance_screen.dart';
import '../../features/referral/presentation/referral_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../state/locale_controller.dart';

// A tiny ChangeNotifier bridge so GoRouter's redirect re-evaluates whenever
// auth or locale state changes, without recreating the router (which would
// lose the navigation stack) on every rebuild.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
    ref.listen(localeControllerProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final locale = ref.read(localeControllerProvider);
      final auth = ref.read(authControllerProvider);
      final path = state.matchedLocation;

      if (path == '/') return null; // splash decides the first hop itself

      if (locale == null) return '/language';

      // '/apply' works for anyone, signed in or not — it's a distinct
      // public flow (become a counselor), not an auth screen — so it's
      // excluded from both checks below rather than folded into
      // guestOnlyRoutes (which would bounce an already-authenticated
      // counselor away from it for no reason).
      if (path == '/apply') return null;

      const guestOnlyRoutes = ['/language', '/login'];
      final isGuestOnlyRoute = guestOnlyRoutes.contains(path);

      if (auth.status == AuthStatus.checking) return null;

      if (auth.status == AuthStatus.unauthenticated && !isGuestOnlyRoute) {
        return '/login';
      }

      if (auth.status == AuthStatus.authenticated && isGuestOnlyRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/language', builder: (context, state) => const LanguageScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/apply', builder: (context, state) => const ApplyScreen()),

      ShellRoute(
        builder: (context, state, child) => AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/clients', builder: (context, state) => const ClientListScreen()),
          GoRoute(
            path: '/browse',
            builder: (context, state) => BrowseScreen(
              forLeadId: state.uri.queryParameters['forLeadId'] != null ? int.parse(state.uri.queryParameters['forLeadId']!) : null,
              forBatchId: state.uri.queryParameters['forBatchId'] != null ? int.parse(state.uri.queryParameters['forBatchId']!) : null,
            ),
          ),
          GoRoute(path: '/interests', builder: (context, state) => const InterestsScreen()),
          GoRoute(path: '/more', builder: (context, state) => const MoreScreen()),
        ],
      ),

      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: '/guide', builder: (context, state) => const GuideScreen()),

      GoRoute(path: '/clients/new', builder: (context, state) => const ClientCreateScreen()),
      GoRoute(
        path: '/clients/:id',
        builder: (context, state) => ClientDetailScreen(leadId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/clients/:id/profile',
        builder: (context, state) => WalkInWizardScreen(leadId: int.parse(state.pathParameters['id']!)),
      ),

      GoRoute(
        path: '/browse/:id',
        builder: (context, state) => CandidateDetailScreen(profileId: int.parse(state.pathParameters['id']!)),
      ),

      GoRoute(path: '/commission', builder: (context, state) => const CommissionScreen()),
      GoRoute(path: '/performance', builder: (context, state) => const PerformanceScreen()),
      GoRoute(path: '/referral', builder: (context, state) => const ReferralScreen()),
      GoRoute(path: '/application', builder: (context, state) => const ApplicationScreen()),
    ],
  );
});
