import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/collection_dashboard_provider.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../../../core/enums/batch_status.dart';
import '../providers/collection_batches_provider.dart';

class CollectionDashboardScreen extends ConsumerStatefulWidget {
  const CollectionDashboardScreen({super.key});

  @override
  ConsumerState<CollectionDashboardScreen> createState() =>
      _CollectionDashboardScreenState();
}

class _CollectionDashboardScreenState
    extends ConsumerState<CollectionDashboardScreen> {
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
        title: const Text('Collection Center'),
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
                'Welcome, ${user?.fullName ?? "Staff"}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              _buildKPISection(context, theme),
              const SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
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
                    onTap: () =>
                        context.pushNamed(RouteNames.collectionCreateBatch),
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'My Batches',
                    icon: Icons.local_drink_outlined,
                    color: theme.colorScheme.secondary,
                    onTap: () =>
                        context.pushNamed(RouteNames.collectionBatches),
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Quality Checks',
                    icon: Icons.fact_check_outlined,
                    color: Colors.orange,
                    onTap: () {
                      ref.read(batchFilterProvider.notifier).updateStatusFilter(BatchStatus.pendingQuality);
                      context.pushNamed(RouteNames.collectionBatches);
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Alerts',
                    icon: Icons.notifications_active_outlined,
                    color: theme.colorScheme.error,
                    onTap: () => context.pushNamed(RouteNames.collectionAlerts),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildKPISection(BuildContext context, ThemeData theme) {
    final statsAsync = ref.watch(collectionDashboardStatsProvider);

    return statsAsync.when(
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
              'Today\'s Litres',
              '${stats['todayTotalLitres'] ?? 0} L',
              Icons.water_drop,
              color: Colors.blue,
            ),
            _buildKPICard(
              theme,
              'Today\'s Batches',
              '${stats['todayBatchCount'] ?? 0}',
              Icons.list_alt,
            ),
            _buildKPICard(
              theme,
              'Accepted',
              '${stats['acceptedCount'] ?? 0}',
              Icons.check_circle,
              color: Colors.green,
            ),
            _buildKPICard(
              theme,
              'Rejected',
              '${stats['rejectedCount'] ?? 0}',
              Icons.cancel,
              color: Colors.red,
            ),
            _buildKPICard(
              theme,
              'Pending Quality',
              '${stats['pendingQualityCount'] ?? 0}',
              Icons.science,
              color: Colors.orange,
            ),
            _buildKPICard(
              theme,
              'Unresolved Alerts',
              '${stats['unresolvedAlerts'] ?? 0}',
              Icons.warning_amber,
              color: Colors.redAccent,
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Error loading stats: $e',
          style: TextStyle(color: theme.colorScheme.error),
        ),
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
}
