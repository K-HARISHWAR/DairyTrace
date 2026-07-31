import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/enums/delivery_status.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/models/delivery_model.dart';
import '../providers/deliveries_provider.dart';

class DistributorDashboardScreen extends ConsumerStatefulWidget {
  const DistributorDashboardScreen({super.key});

  @override
  ConsumerState<DistributorDashboardScreen> createState() => _DistributorDashboardScreenState();
}

class _DistributorDashboardScreenState extends ConsumerState<DistributorDashboardScreen> {
  DeliveryStatus? _statusFilter;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final deliveriesAsync = ref.watch(deliveriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distributor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(deliveriesProvider.notifier).fetchDeliveries(),
          ),
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
        child: RefreshIndicator(
          onRefresh: () => ref.read(deliveriesProvider.notifier).fetchDeliveries(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${user?.fullName ?? "Distributor"}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFilters(),
                    ],
                  ),
                ),
              ),
              deliveriesAsync.when(
                data: (deliveries) {
                  final filtered = _statusFilter == null
                      ? deliveries
                      : deliveries.where((d) => d.status == _statusFilter).toList();

                  if (filtered.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: Text('No deliveries found.')),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildDeliveryCard(context, filtered[index]);
                      },
                      childCount: filtered.length,
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, st) => SliverFillRemaining(
                  child: Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', null),
          const SizedBox(width: 8),
          _buildFilterChip('Assigned', DeliveryStatus.assigned),
          const SizedBox(width: 8),
          _buildFilterChip('In Transit', DeliveryStatus.inTransit),
          const SizedBox(width: 8),
          _buildFilterChip('Delayed', DeliveryStatus.delayed),
          const SizedBox(width: 8),
          _buildFilterChip('Delivered', DeliveryStatus.delivered),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, DeliveryStatus? status) {
    final isSelected = _statusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = selected ? status : null;
        });
      },
    );
  }

  Widget _buildDeliveryCard(BuildContext context, DeliveryModel delivery) {
    final dateFormat = DateFormat('MMM dd, hh:mm a');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  delivery.batchCode ?? 'Unknown Batch',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                _buildStatusBadge(delivery.status),
              ],
            ),
            const Divider(),
            _buildInfoRow(Icons.business, 'Source', '${delivery.farmName ?? "Farm"} -> ${delivery.collectionCentreName ?? "Centre"}'),
            _buildInfoRow(Icons.scale, 'Quantity', '${delivery.quantityLitres ?? 0} L'),
            _buildInfoRow(Icons.local_shipping, 'Vehicle', delivery.vehicleNumber ?? 'Not assigned'),
            if (delivery.expectedPickupAt != null)
              _buildInfoRow(Icons.schedule, 'Exp. Pickup', dateFormat.format(delivery.expectedPickupAt!)),
            if (delivery.expectedDeliveryAt != null)
              _buildInfoRow(Icons.event_available, 'Exp. Delivery', dateFormat.format(delivery.expectedDeliveryAt!)),
            
            const SizedBox(height: 16),
            _buildActionButtons(context, delivery),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(DeliveryStatus status) {
    Color color;
    switch (status) {
      case DeliveryStatus.delivered:
        color = Colors.green;
        break;
      case DeliveryStatus.delayed:
        color = Colors.orange;
        break;
      case DeliveryStatus.cancelled:
        color = Colors.red;
        break;
      case DeliveryStatus.inTransit:
        color = Colors.blue;
        break;
      case DeliveryStatus.pickedUp:
        color = Colors.teal;
        break;
      case DeliveryStatus.assigned:
      default:
        color = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.value.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, DeliveryModel delivery) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        if (delivery.status == DeliveryStatus.assigned)
          ElevatedButton.icon(
            onPressed: () => _showUpdateDialog(context, delivery, DeliveryStatus.pickedUp),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Confirm Pickup'),
          ),
        if (delivery.status == DeliveryStatus.pickedUp)
          ElevatedButton.icon(
            onPressed: () => _showUpdateDialog(context, delivery, DeliveryStatus.inTransit),
            icon: const Icon(Icons.directions_car, size: 18),
            label: const Text('Mark In Transit'),
          ),
        if (delivery.status == DeliveryStatus.inTransit || delivery.status == DeliveryStatus.pickedUp)
          OutlinedButton.icon(
            onPressed: () => _showUpdateDialog(context, delivery, DeliveryStatus.delayed),
            icon: const Icon(Icons.warning_amber, size: 18, color: Colors.orange),
            label: const Text('Report Delay', style: TextStyle(color: Colors.orange)),
          ),
        if (delivery.status == DeliveryStatus.inTransit || delivery.status == DeliveryStatus.delayed)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () => _showUpdateDialog(context, delivery, DeliveryStatus.delivered),
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Mark Delivered'),
          ),
      ],
    );
  }

  void _showUpdateDialog(BuildContext context, DeliveryModel delivery, DeliveryStatus newStatus) {
    final reasonController = TextEditingController();
    final locationController = TextEditingController();
    final notesController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update to ${newStatus.value.replaceAll('_', ' ').toUpperCase()}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (newStatus == DeliveryStatus.delayed)
                      TextField(
                        controller: reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Delay Reason *',
                          hintText: 'Required',
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location Name (Optional)',
                        hintText: 'e.g. Highway 1 Checkpoint',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (newStatus == DeliveryStatus.delayed && reasonController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Delay reason is required.')),
                            );
                            return;
                          }

                          setState(() => isLoading = true);
                          try {
                            await ref.read(deliveriesProvider.notifier).updateDeliveryStatus(
                                  deliveryId: delivery.id,
                                  status: newStatus,
                                  delayReason: newStatus == DeliveryStatus.delayed ? reasonController.text.trim() : null,
                                  locationName: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
                                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                                );
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Status updated successfully')),
                              );
                            }
                          } catch (e) {
                            setState(() => isLoading = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                  child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
