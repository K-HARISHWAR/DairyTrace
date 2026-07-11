import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums/batch_stage.dart';
import '../../../../app/router/route_names.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../batches/presentation/providers/batches_provider.dart';
import '../../../batches/data/repositories/batch_repository.dart';
import 'package:geolocator/geolocator.dart';

class DistributorDashboardScreen extends ConsumerWidget {
  const DistributorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesState = ref.watch(batchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distributor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).signOut(),
          )
        ],
      ),
      body: batchesState.when(
        data: (batches) {
          final activeBatches = batches.where((b) => [BatchStage.accepted, BatchStage.inTransit, BatchStage.delayed].contains(b.stage)).toList();

          if (activeBatches.isEmpty) {
            return const Center(child: Text('No active batches to distribute.'));
          }

          return ListView.builder(
            itemCount: activeBatches.length,
            itemBuilder: (context, index) {
              final batch = activeBatches[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(batch.batchCode ?? 'Unknown Code'),
                  subtitle: Text('Status: ${batch.stage.value}'),
                  trailing: _buildActions(context, ref, batch.id, batch.stage),
                  onTap: () => context.pushNamed(RouteNames.batchDetails, pathParameters: {'id': batch.id}),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, String batchId, BatchStage currentStage) {
    return PopupMenuButton<BatchStage>(
      onSelected: (stage) async {
        try {
          // Attempt to get location quietly
          double? lat;
          double? lng;
          if (await Geolocator.isLocationServiceEnabled()) {
             final permission = await Geolocator.checkPermission();
             if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
               final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
               lat = position.latitude;
               lng = position.longitude;
             }
          }

          await ref.read(batchRepositoryProvider).updateBatchStage(
            batchId: batchId,
            newStage: stage,
            lat: lat,
            lng: lng,
            notes: 'Updated by distributor',
          );
          ref.read(batchesProvider.notifier).fetchBatches();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stage updated')));
          }
        } catch (e) {
          if (context.mounted) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
      },
      itemBuilder: (context) {
        return [
          if (currentStage == BatchStage.accepted || currentStage == BatchStage.delayed)
            const PopupMenuItem(value: BatchStage.inTransit, child: Text('Mark In Transit')),
          if (currentStage == BatchStage.inTransit)
            const PopupMenuItem(value: BatchStage.delayed, child: Text('Mark Delayed')),
          if (currentStage == BatchStage.inTransit || currentStage == BatchStage.delayed)
            const PopupMenuItem(value: BatchStage.delivered, child: Text('Mark Delivered')),
        ];
      },
    );
  }
}
