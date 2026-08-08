import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/admin_farms_centres_provider.dart';
import '../../../farms/data/models/farm_model.dart';
import '../../data/models/centre_model.dart';

class AdminFarmsCentresScreen extends ConsumerStatefulWidget {
  const AdminFarmsCentresScreen({super.key});

  @override
  ConsumerState<AdminFarmsCentresScreen> createState() =>
      _AdminFarmsCentresScreenState();
}

class _AdminFarmsCentresScreenState extends ConsumerState<AdminFarmsCentresScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Farms & Centers'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Farms'),
              Tab(text: 'Collection Centers'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _FarmsTab(),
            _CentresTab(),
          ],
        ),
      ),
    );
  }
}

class _FarmsTab extends ConsumerWidget {
  const _FarmsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmsAsync = ref.watch(adminPaginatedFarmsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search farms...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (val) => ref.read(adminFarmsFilterProvider.notifier).updateSearchQuery(val),
          ),
        ),
        Expanded(
          child: farmsAsync.when(
            data: (farms) {
              if (farms.isEmpty) {
                return const Center(child: Text('No farms found.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: farms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final farm = farms[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                farm.farmName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                farm.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: farm.isActive ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Code: ${farm.farmCode} | Owner: ${farm.ownerName}'),
                          if (farm.village != null)
                            Text('Location: ${farm.village}, ${farm.district ?? ''}'),
                          Text(
                            'Registered: ${DateFormat('dd MMM yyyy').format(farm.createdAt)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
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
    );
  }
}

class _CentresTab extends ConsumerWidget {
  const _CentresTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centresAsync = ref.watch(adminPaginatedCentresProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search centers...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (val) => ref.read(adminCentresFilterProvider.notifier).updateSearchQuery(val),
          ),
        ),
        Expanded(
          child: centresAsync.when(
            data: (centres) {
              if (centres.isEmpty) {
                return const Center(child: Text('No centers found.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: centres.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final centre = centres[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                centre.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                centre.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: centre.isActive ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Code: ${centre.centreCode}'),
                          if (centre.village != null)
                            Text('Location: ${centre.village}, ${centre.district ?? ''}'),
                          Text(
                            'Registered: ${DateFormat('dd MMM yyyy').format(centre.createdAt)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
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
    );
  }
}
