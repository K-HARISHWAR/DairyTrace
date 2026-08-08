import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/batch_stage.dart';
import '../../../../core/enums/batch_status.dart';
import '../providers/admin_batches_provider.dart';

class AdminBatchesScreen extends ConsumerStatefulWidget {
  const AdminBatchesScreen({super.key});

  @override
  ConsumerState<AdminBatchesScreen> createState() =>
      _AdminBatchesScreenState();
}

class _AdminBatchesScreenState extends ConsumerState<AdminBatchesScreen> {
  @override
  Widget build(BuildContext context) {
    final filterArgs = ref.watch(adminBatchFilterProvider);
    final batchesAsync = ref.watch(adminPaginatedBatchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Batches'),
      ),
      body: Column(
        children: [
          _buildFilters(context, filterArgs),
          Expanded(
            child: batchesAsync.when(
              data: (batches) {
                if (batches.isEmpty) {
                  return const Center(child: Text('No batches found.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: batches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final batch = batches[index];
                    return Card(
                      child: InkWell(
                        onTap: () => context.pushNamed(
                          RouteNames.adminBatchDetails,
                          extra: batch,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    batch.batchCode,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${batch.quantityLitres} L',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Collected: ${DateFormat('dd MMM yyyy, HH:mm').format(batch.collectionTime)}',
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildChip(
                                    batch.currentStage.value.toUpperCase(),
                                    Colors.purple,
                                  ),
                                  _buildChip(
                                    batch.qualityStatus.value.toUpperCase(),
                                    _getQualityColor(batch.qualityStatus.value),
                                  ),
                                  _buildChip(
                                    batch.overallStatus.value.toUpperCase(),
                                    _getStatusColor(batch.overallStatus),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getQualityColor(String status) {
    if (status == 'passed') return Colors.green;
    if (status == 'failed') return Colors.red;
    return Colors.orange;
  }

  Color _getStatusColor(BatchStatus status) {
    switch (status) {
      case BatchStatus.accepted:
      case BatchStatus.delivered:
        return Colors.green;
      case BatchStatus.rejected:
      case BatchStatus.spoiled:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Widget _buildFilters(BuildContext context, AdminBatchFilterArgs filterArgs) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search batch code...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (val) => ref.read(adminBatchFilterProvider.notifier).updateSearchQuery(val),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DropdownMenu<BatchStage?>(
                  initialSelection: filterArgs.stageFilter,
                  label: const Text('Stage'),
                  onSelected: (val) => ref.read(adminBatchFilterProvider.notifier).updateStageFilter(val),
                  dropdownMenuEntries: [
                    const DropdownMenuEntry(value: null, label: 'All Stages'),
                    ...BatchStage.values.map(
                      (e) => DropdownMenuEntry(value: e, label: e.value),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                DropdownMenu<BatchStatus?>(
                  initialSelection: filterArgs.statusFilter,
                  label: const Text('Status'),
                  onSelected: (val) => ref.read(adminBatchFilterProvider.notifier).updateStatusFilter(val),
                  dropdownMenuEntries: [
                    const DropdownMenuEntry(value: null, label: 'All Statuses'),
                    ...BatchStatus.values.map(
                      (e) => DropdownMenuEntry(value: e, label: e.value),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
