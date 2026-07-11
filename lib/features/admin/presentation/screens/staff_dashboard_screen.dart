import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../farms/presentation/providers/farms_provider.dart';

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmsState = ref.watch(farmsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).signOut(),
          )
        ],
      ),
      body: farmsState.when(
        data: (farms) {
          if (farms.isEmpty) {
            return const Center(child: Text('No farms registered yet.'));
          }
          return ListView.builder(
            itemCount: farms.length,
            itemBuilder: (context, index) {
              final farm = farms[index];
              return ListTile(
                title: Text(farm.farmerName),
                subtitle: Text(farm.phone ?? 'No phone'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  context.pushNamed(RouteNames.createBatch);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'reg_farm',
            onPressed: () => context.pushNamed(RouteNames.registerFarm),
            icon: const Icon(Icons.add),
            label: const Text('Register Farm'),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'create_batch',
            onPressed: () => context.pushNamed(RouteNames.createBatch),
            icon: const Icon(Icons.water_drop),
            label: const Text('Create Batch'),
          ),
        ],
      ),
    );
  }
}
