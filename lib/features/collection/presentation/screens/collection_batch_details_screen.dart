import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../app/router/route_names.dart';
import '../../../batches/data/models/batch_model.dart';
import '../providers/collection_batch_details_provider.dart';

class CollectionBatchDetailsScreen extends ConsumerWidget {
  final BatchModel batch;

  const CollectionBatchDetailsScreen({super.key, required this.batch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(batch.batchCode),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Quality'),
              Tab(text: 'Journey'),
              Tab(text: 'Delivery'),
              Tab(text: 'QR'),
            ],
          ),
          actions: [
            if (batch.overallStatus.value != 'rejected' &&
                batch.overallStatus.value != 'spoiled' &&
                batch.currentStage.value != 'delivered')
              IconButton(
                icon: const Icon(Icons.edit_location_alt),
                onPressed: () => context.pushNamed(
                  RouteNames.collectionBatchStageUpdate,
                  extra: batch,
                ),
              ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context, ref),
            _buildQualityTab(context, ref),
            _buildJourneyTab(context, ref),
            _buildDeliveryTab(context, ref),
            _buildQRTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Batch Code', batch.batchCode),
          _buildDetailRow('Quantity', '${batch.quantityLitres} L'),
          _buildDetailRow(
            'Collection Time',
            DateFormat('dd MMM yyyy, HH:mm').format(batch.collectionTime),
          ),
          _buildDetailRow('Stage', batch.currentStage.value.toUpperCase()),
          _buildDetailRow('Status', batch.overallStatus.value.toUpperCase()),
          _buildDetailRow('Quality', batch.qualityStatus.value.toUpperCase()),
          if (batch.notes != null) _buildDetailRow('Notes', batch.notes!),
          const Divider(height: 32),
          const Text(
            'Source Farm',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          ref
              .watch(batchFarmProvider(batch.farmId))
              .when(
                data: (farm) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Farm Name', farm.farmName),
                    _buildDetailRow('Owner', farm.ownerName),
                    _buildDetailRow(
                      'Location',
                      '${farm.village}, ${farm.district ?? ''}',
                    ),
                  ],
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error loading farm: $e'),
              ),
        ],
      ),
    );
  }

  Widget _buildQualityTab(BuildContext context, WidgetRef ref) {
    return ref
        .watch(batchQualityProvider(batch.id))
        .when(
          data: (checks) {
            if (checks.isEmpty) {
              return const Center(child: Text('No quality checks recorded.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: checks.length,
              itemBuilder: (context, index) {
                final check = checks[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Checkpoint: ${check.checkpoint.toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Evaluated Result: ${check.evaluatedResult}',
                        ),
                        Text(
                          'Fat: ${check.fatPercentage ?? "N/A"}% | SNF: ${check.snfPercentage ?? "N/A"}%',
                        ),
                        Text(
                          'Temp: ${check.temperatureC ?? "N/A"}°C | Purity Passed: ${check.purityPassed == true ? "Yes" : "No"}',
                        ),
                        Text(
                          'Time: ${DateFormat('dd MMM yyyy, HH:mm').format(check.checkedAt)}',
                        ),
                        if (check.remarks != null)
                          Text('Remarks: ${check.remarks}'),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
  }

  Widget _buildJourneyTab(BuildContext context, WidgetRef ref) {
    return ref
        .watch(batchTrackingProvider(batch.id))
        .when(
          data: (events) {
            if (events.isEmpty) {
              return const Center(child: Text('No tracking events.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  leading: const Icon(Icons.commit),
                  title: Text(
                    event.stage.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.status),
                      if (event.locationName != null)
                        Text('Location: ${event.locationName}'),
                      Text(
                        DateFormat(
                          'dd MMM yyyy, HH:mm',
                        ).format(event.occurredAt),
                      ),
                      if (event.remarks != null)
                        Text('Remarks: ${event.remarks}'),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
  }

  Widget _buildDeliveryTab(BuildContext context, WidgetRef ref) {
    // Delivery implementation will come later.
    return const Center(
      child: Text('Delivery assignment and progress tracking.'),
    );
  }

  Widget _buildQRTab(BuildContext context) {
    final token = batch.publicToken;
    final qrData = 'DAIRYTRACE:$token';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (batch.overallStatus.value == 'rejected' ||
              batch.overallStatus.value == 'spoiled')
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade100,
              child: const Text(
                'WARNING: This batch has been rejected or spoiled. It should not be distributed.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 32),
          Center(
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250.0,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Batch: ${batch.batchCode}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scan this QR code with the DairyTrace scanner to view the public journey.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
