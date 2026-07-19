import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/authentication/presentation/screens/welcome_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../../features/admin/presentation/screens/admin_create_user_screen.dart';

import '../../features/collection/presentation/screens/collection_dashboard_screen.dart';

import '../../features/deliveries/presentation/screens/distributor_dashboard_screen.dart';
import '../../features/public_trace/presentation/screens/public_scan_screen.dart';
import '../../features/public_trace/presentation/screens/public_batch_screen.dart';

// Dummy placeholder for screens yet to be built
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: RouteNames.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/inactive_account',
        name: RouteNames.inactiveAccount,
        builder: (context, state) => const PlaceholderScreen(title: 'Account Inactive'),
      ),
      // Admin Module
      GoRoute(
        path: '/admin',
        name: RouteNames.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: RouteNames.adminUsers,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin/users/create',
        name: 'admin_create_user',
        builder: (context, state) => const AdminCreateUserScreen(),
      ),
      // Collection Module
      GoRoute(
        path: '/collection',
        name: RouteNames.collectionDashboard,
        builder: (context, state) => const CollectionDashboardScreen(),
      ),
      // Distributor Module
      GoRoute(
        path: '/distributor',
        name: RouteNames.distributorDashboard,
        builder: (context, state) => const DistributorDashboardScreen(),
      ),
      // Public Trace
      GoRoute(
        path: '/scan',
        name: RouteNames.scan,
        builder: (context, state) => const PublicScanScreen(),
      ),
      GoRoute(
        path: '/public_batch/:token',
        name: RouteNames.publicBatch,
        builder: (context, state) => PublicBatchScreen(publicToken: state.pathParameters['token']!),
      ),
    ],
  );
});
