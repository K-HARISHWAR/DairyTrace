import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_dashboard_charts.dart';
import '../../../../core/services/local_notification_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocalNotificationService().requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).signOut();
              if (context.mounted) {
                context.goNamed(RouteNames.welcome);
              }
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
                'Welcome, ${user?.fullName ?? "Admin"}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              _buildKPISection(context, theme),
              const SizedBox(height: 24),
              _buildChartsSection(context, theme),
              const SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildDashboardGrid(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPISection(BuildContext context, ThemeData theme) {
    final statsAsyncValue = ref.watch(adminDashboardStatsProvider);

    return statsAsyncValue.when(
      data: (stats) {
        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          childAspectRatio: 1.5,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildKPICard(
              theme,
              'Active Batches',
              stats['totalActiveBatches']?.toString() ?? '0',
              Icons.local_drink,
            ),
            _buildKPICard(
              theme,
              'Collected Today',
              stats['batchesCollectedToday']?.toString() ?? '0',
              Icons.today,
            ),
            _buildKPICard(
              theme,
              'Accepted',
              stats['acceptedBatches']?.toString() ?? '0',
              Icons.check_circle_outline,
              color: Colors.green,
            ),
            _buildKPICard(
              theme,
              'Rejected',
              stats['rejectedBatches']?.toString() ?? '0',
              Icons.cancel_outlined,
              color: Colors.red,
            ),
            _buildKPICard(
              theme,
              'In Transit',
              stats['inTransitDeliveries']?.toString() ?? '0',
              Icons.local_shipping_outlined,
            ),
            _buildKPICard(
              theme,
              'Delayed',
              stats['delayedDeliveries']?.toString() ?? '0',
              Icons.access_time_outlined,
              color: Colors.orange,
            ),
            _buildKPICard(
              theme,
              'Unresolved Alerts',
              stats['unresolvedAlerts']?.toString() ?? '0',
              Icons.warning_amber,
            ),
            _buildKPICard(
              theme,
              'Critical Alerts',
              stats['highCriticalAlerts']?.toString() ?? '0',
              Icons.error_outline,
              color: Colors.red,
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text(
        'Failed to load stats: $error',
        style: TextStyle(color: theme.colorScheme.error),
      ),
    );
  }

  Widget _buildKPICard(
    ThemeData theme,
    String title,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final iconColor = color ?? theme.colorScheme.primary;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, ThemeData theme) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);
    final volumeAsync = ref.watch(adminDailyVolumeProvider(7)); // last 7 days

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Batch Status Overview',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  statsAsync.when(
                    data: (stats) => DashboardStatusDoughnut(stats: stats),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7-Day Collection Volume',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  volumeAsync.when(
                    data: (data) => DashboardVolumeChart(data: data),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardGrid(BuildContext context, ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildDashboardCard(
          context,
          title: 'Users & Roles',
          icon: Icons.people_outline,
          color: theme.colorScheme.primary,
          onTap: () => context.pushNamed(RouteNames.adminUsers),
        ),
        _buildDashboardCard(
          context,
          title: 'System Alerts',
          icon: Icons.warning_amber_rounded,
          color: theme.colorScheme.error,
          onTap: () => context.pushNamed(RouteNames.adminAlerts),
        ),
        _buildDashboardCard(
          context,
          title: 'All Batches',
          icon: Icons.local_drink_outlined,
          color: theme.colorScheme.secondary,
          onTap: () {},
        ),
        _buildDashboardCard(
          context,
          title: 'Farms & Centers',
          icon: Icons.agriculture_outlined,
          color: theme.colorScheme.tertiary,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
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
