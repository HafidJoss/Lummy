import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/challenge_session/presentation/pages/challenge_page.dart';
import '../../features/dashboard/presentation/pages/mission_selection_page.dart';
import '../../features/dashboard/presentation/pages/profile_page.dart';
import '../../features/leaderboard/presentation/pages/leaderboard_page.dart';
import '../widgets/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _sectionANavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sectionANav');
final GlobalKey<NavigatorState> _sectionBNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sectionBNav');
final GlobalKey<NavigatorState> _sectionCNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sectionCNav');
final GlobalKey<NavigatorState> _sectionDNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sectionDNav');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) async {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (token == null && !isAuthRoute) {
        return '/login';
      }

      if (token != null && isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/challenge',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ChallengePage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _sectionANavigatorKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _sectionBNavigatorKey,
            routes: [
              GoRoute(
                path: '/mission-selection',
                builder: (context, state) => const MissionSelectionPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _sectionCNavigatorKey,
            routes: [
              GoRoute(
                path: '/leaderboard',
                builder: (context, state) => const LeaderboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _sectionDNavigatorKey,
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
