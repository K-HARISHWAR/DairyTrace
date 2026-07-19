import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class CollectionDashboardScreen extends ConsumerWidget {
  const CollectionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${user?.fullName ?? "Staff"}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildDashboardCard(
                    context,
                    title: 'Farms',
                    icon: Icons.agriculture_outlined,
                    color: theme.colorScheme.tertiary,
                    onTap: () => context.pushNamed(RouteNames.collectionFarms),
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Receive Batch',
                    icon: Icons.add_circle_outline,
                    color: theme.colorScheme.primary,
                    onTap: () => context.pushNamed(RouteNames.collectionCreateBatch),
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'My Batches',
                    icon: Icons.local_drink_outlined,
                    color: theme.colorScheme.secondary,
                    onTap: () => context.pushNamed(RouteNames.collectionBatches),
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Quality Checks',
                    icon: Icons.fact_check_outlined,
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Alerts',
                    icon: Icons.notifications_active_outlined,
                    color: theme.colorScheme.error,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
