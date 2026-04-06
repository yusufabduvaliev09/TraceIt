import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:traceit/features/auth/presentation/auth_screen.dart';
import 'package:traceit/features/main_screen.dart';
import 'package:traceit/features/profile/profile_screen.dart';
import 'package:traceit/features/admin/presentation/admin_panel_screen.dart';
import 'package:traceit/features/admin/presentation/admin_pvz_management_screen.dart';
import 'package:traceit/features/admin/presentation/admin_china_template_screen.dart';
import 'package:traceit/features/admin/presentation/admin_whatsapp_templates_screen.dart';
import 'package:traceit/features/cargo/presentation/cargo_status_list_screen.dart';
import 'package:traceit/features/cargo/presentation/track_search_screen.dart';
import 'package:traceit/features/notifications/presentation/notifications_screen.dart';
import 'package:traceit/features/home/presentation/placeholder_screens.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final path = state.matchedLocation;
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final loggingIn = path == '/auth';
    final goingAdmin = path.startsWith('/admin');

    if (!loggedIn && !loggingIn) return '/auth';
    if (loggedIn && loggingIn) return '/main';
    if (goingAdmin) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final role = (doc.data()?['role'] ?? 'user').toString();
      if (role != 'admin' && role != 'dev') {
        return '/main';
      }
    }
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
    GoRoute(
      path: '/admin/settings/pvz',
      builder: (context, state) => const AdminPvzManagementScreen(),
    ),
    GoRoute(
      path: '/admin/settings/china-template',
      builder: (context, state) => const AdminChinaTemplateScreen(),
    ),
    GoRoute(
      path: '/admin/settings/whatsapp',
      builder: (context, state) => const AdminWhatsappTemplatesScreen(),
    ),
    GoRoute(
      path: '/cargo/:status',
      builder: (context, state) {
        final status = state.pathParameters['status'] ?? 'pending';
        return CargoStatusListScreen(statusKey: status);
      },
    ),
    GoRoute(
      path: '/track-search',
      builder: (context, state) {
        final q = state.uri.queryParameters['q'] ?? '';
        return TrackSearchScreen(initialQuery: q);
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/map-route',
      builder: (context, state) => const MapRoutePlaceholderScreen(),
    ),
    GoRoute(
      path: '/unknown-parcels',
      builder: (context, state) => const UnknownParcelsPlaceholderScreen(),
    ),
    GoRoute(
      path: '/instruction',
      builder: (context, state) => const InstructionPlaceholderScreen(),
    ),
  ],
);