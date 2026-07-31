import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/enums/batch_status.dart';
import '../../../../core/utils/qr_parser.dart';
import '../providers/batches_provider.dart';

class BatchQrScreen extends ConsumerStatefulWidget {
  final String batchId;

  const BatchQrScreen({super.key, required this.batchId});

  @override
  ConsumerState<BatchQrScreen> createState() => _BatchQrScreenState();
}

class _BatchQrScreenState extends ConsumerState<BatchQrScreen> {
  final TextEditingController _debugTokenController = TextEditingController();

  @override
  void dispose() {
    _debugTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final batchAsync = ref.watch(batchByIdProvider(widget.batchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch QR Code'),
      ),
      body: batchAsync.when(
        data: (batch) {
          final isRejectedOrSpoiled = batch.overallStatus == BatchStatus.rejected || 
                                      batch.overallStatus == BatchStatus.spoiled;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isRejectedOrSpoiled)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'WARNING: This batch is marked as ${batch.overallStatus.value.toUpperCase()}.',
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const Text(
                  'Public Trace Code',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan this code to view the public journey of this milk batch.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                
                // QR Code
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: QrImageView(
                      data: '${QrParser.prefix}${batch.publicToken}',
                      version: QrVersions.auto,
                      size: 250.0,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Batch Details
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDetailRow('Batch Code', batch.batchCode),
                        const Divider(),
                        _buildDetailRow('Status', batch.overallStatus.value.toUpperCase()),
                        const Divider(),
                        _buildDetailRow('Quantity', '${batch.quantityLitres} L'),
                      ],
                    ),
                  ),
                ),
                
                // Debug Options
                if (kDebugMode) ...[
                  const SizedBox(height: 48),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Debug: Manual Token Entry',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _debugTokenController,
                          decoration: const InputDecoration(
                            hintText: 'Enter public token manually',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // This simulates scanning the QR in a debug environment
                          // But wait, the scanner screen is separate.
                          // Usually you'd copy this token and paste it in the scanner.
                          // For ease of use, we can just print it.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copied: ${batch.publicToken}'),
                            ),
                          );
                        },
                        child: const Text('Copy'),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading batch: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
