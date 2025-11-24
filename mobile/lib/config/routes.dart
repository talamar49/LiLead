
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/models/lead.dart';
import '../screens/main_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/leads/new_leads_screen.dart';
import '../screens/leads/follow_up_screen.dart';
import '../screens/leads/closed_leads_screen.dart';
import '../screens/leads/not_relevant_leads_screen.dart';
import '../screens/leads/leads_list_screen.dart';
import '../screens/leads/lead_detail_screen.dart';
import '../screens/leads/add_lead_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../providers/auth_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Custom page transition builder for smooth animations
CustomTransitionPage _buildPageWithTransition({
  required Widget child,
  required GoRouterState state,
  bool isSlideUp = false,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (isSlideUp) {
        // Slide up transition for modals
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      }
      
      // Fade + Scale transition for regular pages
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  // Use a ValueNotifier to trigger router refreshes without rebuilding the router itself
  final authNotifier = ValueNotifier(ref.read(authProvider));
  
  // Update the notifier when auth state changes
  ref.listen(authProvider, (_, next) {
    authNotifier.value = next;
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      // Use ref.read to avoid watching and rebuilding
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.uri.path == '/login' || state.uri.path == '/register';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const LoginScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const RegisterScreen(),
          state: state,
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const DashboardScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/new-leads',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const NewLeadsScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/follow-up',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const FollowUpScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/all-leads',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const LeadsListScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/closed',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const ClosedLeadsScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/not-relevant',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const NotRelevantLeadsScreen(),
              state: state,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/leads/add',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const AddLeadScreen(),
          state: state,
          isSlideUp: true,
        ),
      ),
      GoRoute(
        path: '/leads/:id',
        pageBuilder: (context, state) {
          final lead = state.extra as Lead;
          return _buildPageWithTransition(
            child: LeadDetailScreen(lead: lead),
            state: state,
          );
        },
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const ProfileScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const SettingsScreen(),
          state: state,
        ),
      ),
    ],
  );
});
