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
          context.goNamed(RouteNames.welcome);
        } else {
          final profile = next.value!;
          if (!profile.isActive) {
            context.goNamed(RouteNames.inactiveAccount);
            return;
          }
          final role = profile.role;
          if (role == UserRole.admin) {
            context.goNamed(RouteNames.adminDashboard);
          } else if (role == UserRole.collectionStaff) {
            context.goNamed(RouteNames.collectionDashboard);
          } else if (role == UserRole.distributor) {
            context.goNamed(RouteNames.distributorDashboard);
          } else {
            context.goNamed(RouteNames.welcome);
          }
        }
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 120),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

