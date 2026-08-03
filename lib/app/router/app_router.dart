import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import 'app_routing_readiness_provider.dart';
import '../../core/enums/user_role.dart';

import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/authentication/presentation/screens/welcome_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../../features/admin/presentation/screens/admin_create_user_screen.dart';

import '../../features/collection/presentation/screens/collection_dashboard_screen.dart';
import '../../features/collection/presentation/screens/collection_farms_screen.dart';
import '../../features/collection/presentation/screens/collection_create_farm_screen.dart';
import '../../features/collection/presentation/screens/collection_batches_screen.dart';
import '../../features/collection/presentation/screens/collection_create_batch_screen.dart';
import '../../features/collection/presentation/screens/collection_batch_details_screen.dart';
import '../../features/collection/presentation/screens/collection_batch_stage_update_screen.dart';
import '../../features/batches/data/models/batch_model.dart';
import '../../features/batches/presentation/screens/batch_qr_screen.dart';

import '../../features/deliveries/presentation/screens/distributor_dashboard_screen.dart';
import '../../features/public_trace/presentation/screens/public_scan_screen.dart';
import '../../features/public_trace/presentation/screens/public_batch_screen.dart';
import '../../features/alerts/presentation/screens/alerts_screen.dart';

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
  final readinessNotifier = ref.watch(appRoutingReadinessProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: readinessNotifier,
    redirect: (context, state) {
      final routingState = readinessNotifier.state;
      final path = state.uri.path;

      // Allow public routes
      if (path == '/scan' || path.startsWith('/public_batch/')) {
        return null;
      }

      if (routingState.isLoading) {
        return '/'; // Splash screen
      }

      if (!routingState.isAuthenticated) {
        if (path == '/login') return null;
        return '/welcome';
      }

      if (!routingState.hasProfile) {
        return '/profile-not-configured';
      }

      if (!routingState.isActive) {
        return '/inactive-account';
      }

      // Root path routing for authenticated & active users
      if (path == '/' || path == '/welcome' || path == '/login') {
        switch (routingState.role) {
          case UserRole.admin:
            return '/admin';
          case UserRole.collectionStaff:
            return '/collection';
          case UserRole.distributor:
            return '/distributor';
          default:
            return '/access-denied';
        }
      }

      // Route guard per role
      if (path.startsWith('/admin') && routingState.role != UserRole.admin) {
        return '/access-denied';
      }
      if (path.startsWith('/collection') &&
          routingState.role != UserRole.collectionStaff) {
        return '/access-denied';
      }
      if (path.startsWith('/distributor') &&
          routingState.role != UserRole.distributor) {
        return '/access-denied';
      }

      return null;
    },
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
        path: '/inactive-account',
        name: RouteNames.inactiveAccount,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Account Inactive'),
      ),
      GoRoute(
        path: '/profile-not-configured',
        name: 'profile_not_configured',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Profile Not Configured'),
      ),
      GoRoute(
        path: '/access-denied',
        name: 'access_denied',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Access Denied'),
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
      GoRoute(
        path: '/admin/alerts',
        name: RouteNames.adminAlerts,
        builder: (context, state) => const AlertsScreen(),
      ),
      // Collection Module
      GoRoute(
        path: '/collection',
        name: RouteNames.collectionDashboard,
        builder: (context, state) => const CollectionDashboardScreen(),
      ),
      GoRoute(
        path: '/collection/farms',
        name: RouteNames.collectionFarms,
        builder: (context, state) => const CollectionFarmsScreen(),
      ),
      GoRoute(
        path: '/collection/farms/create',
        name: RouteNames.collectionCreateFarm,
        builder: (context, state) => const CollectionCreateFarmScreen(),
      ),
      GoRoute(
        path: '/collection/batches',
        name: RouteNames.collectionBatches,
        builder: (context, state) => const CollectionBatchesScreen(),
      ),
      GoRoute(
        path: '/collection/batches/create',
        name: RouteNames.collectionCreateBatch,
        builder: (context, state) => const CollectionCreateBatchScreen(),
      ),
      GoRoute(
        path: '/collection/batches/details',
        name: RouteNames.collectionBatchDetails,
        builder: (context, state) =>
            CollectionBatchDetailsScreen(batch: state.extra as BatchModel),
      ),
      GoRoute(
        path: '/collection/batches/update-stage',
        name: RouteNames.collectionBatchStageUpdate,
        builder: (context, state) =>
            CollectionBatchStageUpdateScreen(batch: state.extra as BatchModel),
      ),
      GoRoute(
        path: '/collection/alerts',
        name: RouteNames.collectionAlerts,
        builder: (context, state) => const AlertsScreen(),
      ),
      GoRoute(
        path: '/batches/:id/qr',
        name: 'batch_qr',
        builder: (context, state) =>
            BatchQrScreen(batchId: state.pathParameters['id']!),
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
        builder: (context, state) =>
            PublicBatchScreen(publicToken: state.pathParameters['token']!),
      ),
    ],
  );
});
