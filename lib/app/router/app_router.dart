import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'route_names.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/admin/presentation/screens/staff_dashboard_screen.dart';
import '../../features/farms/presentation/screens/register_farm_screen.dart';
import '../../features/batches/presentation/screens/create_batch_screen.dart';
import '../../features/batches/presentation/screens/batch_details_screen.dart';
import '../../features/distribution/presentation/screens/distributor_dashboard_screen.dart';
import '../../features/customer_scan/presentation/screens/public_scan_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';

// Dummy screens for now
// Dummy screens for now
// Dummy screens for now
// Dummy screens for now
// Dummy screens for now
// Dummy screens for now
// Dummy screens for now

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
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/scan',
        name: RouteNames.publicScan,
        builder: (context, state) => const PublicScanScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: RouteNames.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/staff',
        name: RouteNames.staffDashboard,
        builder: (context, state) => const StaffDashboardScreen(),
      ),
      GoRoute(
        path: '/register_farm',
        name: RouteNames.registerFarm,
        builder: (context, state) => const RegisterFarmScreen(),
      ),
      GoRoute(
        path: '/create_batch',
        name: RouteNames.createBatch,
        builder: (context, state) => const CreateBatchScreen(),
      ),
      GoRoute(
        path: '/batch_details/:id',
        name: RouteNames.batchDetails,
        builder: (context, state) => BatchDetailsScreen(batchId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/distributor',
        name: RouteNames.distributorDashboard,
        builder: (context, state) => const DistributorDashboardScreen(),
      ),
    ],
  );
});
