import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/user_role.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (previous, next) {
      if (next == null) return;
      if (!next.isLoading) {
        if (next.hasError || next.value == null) {
          context.goNamed(RouteNames.login);
        } else {
          final role = next.value!.role;
          if (role == UserRole.admin) {
            context.goNamed(RouteNames.adminDashboard);
          } else if (role == UserRole.collectionStaff) {
            context.goNamed(RouteNames.staffDashboard);
          } else if (role == UserRole.distributor) {
            context.goNamed(RouteNames.distributorDashboard);
          } else {
            context.goNamed(RouteNames.publicScan);
          }
        }
      }
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, size: 100, color: Colors.blue),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
