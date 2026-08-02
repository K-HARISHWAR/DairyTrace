import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/router/route_names.dart';
import '../../data/repositories/public_trace_repository.dart';

import 'dart:async';

class PublicBatchNotifier extends AutoDisposeFamilyAsyncNotifier<Map<String, dynamic>?, String> {
  @override
  FutureOr<Map<String, dynamic>?> build(String arg) async {
    return _fetchBatch(arg);
  }

  Future<Map<String, dynamic>?> _fetchBatch(String token) async {
    return ref.watch(publicTraceRepositoryProvider).getPublicBatchTrace(token);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final batch = await _fetchBatch(arg);
      state = AsyncData(batch);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final publicBatchProvider = AutoDisposeAsyncNotifierProviderFamily<PublicBatchNotifier, Map<String, dynamic>?, String>(PublicBatchNotifier.new);

class PublicBatchScreen extends ConsumerWidget {
  final String publicToken;

  const PublicBatchScreen({super.key, required this.publicToken});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchAsync = ref.watch(publicBatchProvider(publicToken));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Provenance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteNames.welcome);
            }
          },
        ),
      ),
      body: batchAsync.when(
        data: (data) {
          if (data == null || data.isEmpty) {
            return _buildNotFound(context);
          }
          return _buildProvenanceView(context, data);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Could not load batch data.\n\n$err')),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Batch Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'The QR code scanned does not match any public DairyTrace records.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvenanceView(BuildContext context, Map<String, dynamic> data) {
    final bool verified = data['verified'] == true;
    final Map<String, dynamic> batch = data['batch'] ?? {};
    final List<dynamic> qualityChecks = data['qualityChecks'] ?? [];
    final List<dynamic> journey = data['journey'] ?? [];
    final Map<String, dynamic>? delivery = data['delivery'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Verification Card
          Container(
            color: verified ? Colors.green.shade50 : Colors.red.shade50,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  verified ? Icons.verified : Icons.warning,
                  size: 64,
                  color: verified ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 12),
                Text(
                  verified ? 'Verified DairyTrace Batch' : 'Batch Not Verified',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: verified ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoCard(context, batch, delivery),
              ],
            ),
          ),

          // Quality Summary
          if (qualityChecks.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Quality Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _buildQualitySummary(qualityChecks.first),
          ],

          // Journey Timeline
          if (journey.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Journey Timeline',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _buildJourneyTimeline(journey),
          ],

          // Footer
          Container(
            padding: const EdgeInsets.all(32),
            color: Colors.grey.shade100,
            child: const Text(
              'This page shows the traceability information recorded in DairyTrace for this batch. '
              'The data is strictly for provenance tracking and transparency.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Map<String, dynamic> batch, Map<String, dynamic>? delivery) {
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
    final collectionDate = batch['collection_time'] != null
        ? dateFormat.format(DateTime.parse(batch['collection_time']))
        : 'Unknown';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow('Batch Code', batch['batch_code'] ?? 'Unknown', isBold: true),
            const Divider(),
            _buildStatusChipRow('Status', _formatStatus(batch['overall_status'] ?? 'Unknown'), _getStatusColor(batch['overall_status'])),
            const Divider(),
            _buildDetailRow('Stage', _formatStage(batch['current_stage'] ?? 'Unknown')),
            const Divider(),
            _buildDetailRow('Source Farm', '${batch['farm_name'] ?? 'Unknown'} (${batch['farm_village'] ?? 'Unknown'})'),
            const Divider(),
            _buildDetailRow('Collection Centre', batch['collection_centre_name'] ?? 'Unknown'),
            const Divider(),
            _buildDetailRow('Collection Date', collectionDate),
            const Divider(),
            _buildStatusChipRow('Quality State', _formatStatus(batch['quality_status'] ?? 'Unknown'), _getQualityColor(batch['quality_status'])),
            if (delivery != null) ...[
              const Divider(),
              _buildStatusChipRow('Delivery State', _formatStatus(delivery['status'] ?? 'Unknown'), _getDeliveryColor(delivery['status'])),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildQualitySummary(Map<String, dynamic> check) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Checkpoint: ${_formatStage(check['checkpoint'] ?? 'Unknown')}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQualityMetric('Fat %', '${check['fat_percentage'] ?? 'N/A'}%'),
              _buildQualityMetric('SNF %', '${check['snf_percentage'] ?? 'N/A'}%'),
              _buildQualityMetric('Temp', '${check['temperature_celsius'] ?? 'N/A'}°C'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Purity Check', style: TextStyle(color: Colors.black87)),
              Icon(
                check['purity_passed'] == true ? Icons.check_circle : (check['purity_passed'] == false ? Icons.cancel : Icons.help),
                color: check['purity_passed'] == true ? Colors.green : (check['purity_passed'] == false ? Colors.red : Colors.grey),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overall Status', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildStatusChipRow('', _formatStatus(check['evaluated_result'] ?? 'Unknown'), _getQualityColor(check['evaluated_result']), hideLabel: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildJourneyTimeline(List<dynamic> journey) {
    final dateFormat = DateFormat('MMM dd, hh:mm a');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: journey.length,
        itemBuilder: (context, index) {
          final event = journey[index];
          final isFirst = index == 0;
          final isLast = index == journey.length - 1;
          
          final dateStr = event['occurred_at'] != null 
              ? dateFormat.format(DateTime.parse(event['occurred_at']))
              : '';

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timeline line & dot
                SizedBox(
                  width: 30,
                  child: Column(
                    children: [
                      Container(
                        width: 2,
                        height: 20,
                        color: isFirst ? Colors.transparent : Colors.blue.shade200,
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isFirst ? Colors.blue : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isLast ? Colors.transparent : Colors.blue.shade200,
                        ),
                      ),
                    ],
                  ),
                ),
                // Timeline content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 24, top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatStage(event['stage'] ?? 'Unknown'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              dateStr,
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                        if (event['location_name'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  event['location_name'],
                                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        if (event['public_remarks'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                event['public_remarks'],
                                style: const TextStyle(color: Colors.black87, fontSize: 13, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChipRow(String label, String value, Color color, {bool hideLabel = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: hideLabel ? 0 : 4.0),
      child: Row(
        mainAxisAlignment: hideLabel ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
        children: [
          if (!hideLabel) Text(label, style: const TextStyle(color: Colors.black54)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending_quality': return 'Pending';
      case 'accepted': return 'Passed';
      case 'rejected': return 'Rejected';
      case 'in_progress': return 'In Progress';
      case 'delayed': return 'Delayed';
      case 'spoiled': return 'Spoiled';
      case 'delivered': return 'Delivered';
      case 'passed': return 'Passed';
      case 'failed': return 'Failed';
      case 'warning': return 'Warning';
      case 'assigned': return 'Assigned';
      case 'picked_up': return 'Picked Up';
      case 'in_transit': return 'In Transit';
      default: return status.toUpperCase();
    }
  }

  String _formatStage(String stage) {
    return stage.split('_').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'accepted':
      case 'delivered': return Colors.green;
      case 'rejected':
      case 'spoiled': return Colors.red;
      case 'delayed': return Colors.orange;
      default: return Colors.blue;
    }
  }

  Color _getQualityColor(String? status) {
    switch (status) {
      case 'passed':
      case 'accepted': return Colors.green;
      case 'failed':
      case 'rejected': return Colors.red;
      case 'warning': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Color _getDeliveryColor(String? status) {
    switch (status) {
      case 'delivered': return Colors.green;
      case 'delayed': return Colors.orange;
      case 'in_transit': return Colors.blue;
      case 'picked_up': return Colors.teal;
      default: return Colors.grey;
    }
  }
}
