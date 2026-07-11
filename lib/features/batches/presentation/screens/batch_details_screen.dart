import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/enums/batch_stage.dart';
import '../../../../core/enums/quality_result.dart';
import '../providers/batches_provider.dart';

class BatchDetailsScreen extends ConsumerWidget {
  final String batchId;

  const BatchDetailsScreen({super.key, required this.batchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesState = ref.watch(batchesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Batch Details')),
      body: batchesState.when(
        data: (batches) {
          final batch = batches.firstWhere((b) => b.id == batchId);
          final bool isAccepted = batch.stage != BatchStage.rejected && batch.qualityResult == QualityResult.pass;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (batch.batchCode != null)
                  Text('Code: ${batch.batchCode}', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildRow('Quantity', '${batch.quantityLiters} L'),
                        _buildRow('Temperature', '${batch.temperatureCelsius} °C'),
                        _buildRow('Fat %', '${batch.fatPercentage} %'),
                        _buildRow('SNF %', '${batch.snfPercentage} %'),
                        _buildRow('Status', batch.stage.value.toUpperCase()),
                        _buildRow('Quality', batch.qualityResult.value.toUpperCase()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (isAccepted && batch.qrToken != null)
                  Center(
                    child: Column(
                      children: [
                        const Text('Public QR Code', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        QrImageView(
                          data: 'dairytrace://scan/${batch.qrToken}',
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        const SizedBox(height: 8),
                        const Text('Scan this code for public provenance tracking.'),
                      ],
                    ),
                  )
                else if (batch.stage == BatchStage.rejected)
                  const Center(child: Text('Batch was rejected.', style: TextStyle(color: Colors.red))),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
