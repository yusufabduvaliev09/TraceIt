import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:traceit/features/auth/presentation/auth_screen.dart';
import 'package:traceit/features/main_screen.dart';
import 'package:traceit/features/profile/profile_screen.dart';
import 'package:traceit/features/admin/presentation/admin_panel_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final loggingIn = state.matchedLocation == '/auth';

    if (!loggedIn && !loggingIn) return '/auth';
    if (loggedIn && loggingIn) return '/main';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminPanelScreen(),
    ),
  ],
);