
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

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
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
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/new-leads',
            builder: (context, state) => const NewLeadsScreen(),
          ),
          GoRoute(
            path: '/follow-up',
            builder: (context, state) => const FollowUpScreen(),
          ),
          GoRoute(
            path: '/all-leads',
            builder: (context, state) => const LeadsListScreen(),
          ),
          GoRoute(
            path: '/closed',
            builder: (context, state) => const ClosedLeadsScreen(),
          ),
          GoRoute(
            path: '/not-relevant',
            builder: (context, state) => const NotRelevantLeadsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/leads/add',
        parentNavigatorKey: _rootNavigatorKey, // Full screen modal
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: AddLeadScreen(),
        ),
      ),
      GoRoute(
        path: '/leads/:id',
        builder: (context, state) {
          final lead = state.extra as Lead;
          return LeadDetailScreen(lead: lead);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
