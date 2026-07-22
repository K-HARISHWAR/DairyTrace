import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../providers/collection_farms_provider.dart';

class CollectionFarmsScreen extends ConsumerStatefulWidget {
  const CollectionFarmsScreen({super.key});

  @override
  ConsumerState<CollectionFarmsScreen> createState() => _CollectionFarmsScreenState();
}

class _CollectionFarmsScreenState extends ConsumerState<CollectionFarmsScreen> {
  String _searchQuery = '';
  bool? _isActiveFilter;

  @override
  Widget build(BuildContext context) {
    final args = FarmFilterArgs(searchQuery: _searchQuery, isActive: _isActiveFilter);
    final farmsAsync = ref.watch(paginatedFarmsProvider(args));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.pushNamed(RouteNames.collectionCreateFarm),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(context),
          Expanded(
            child: farmsAsync.when(
              data: (farms) {
                if (farms.isEmpty) {
                  return const Center(child: Text('No farms found.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: farms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final farm = farms[index];
                    return Card(
                      child: ListTile(
                        title: Text('${farm.farmName} (${farm.farmCode})', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${farm.ownerName} • ${farm.village}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: farm.isActive ? Colors.green.shade100 : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            farm.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: farm.isActive ? Colors.green.shade800 : Colors.red.shade800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          // View farm details or edit
                        },
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

  Widget _buildFilters(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search farm, code, owner, or village...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DropdownMenu<bool?>(
                  initialSelection: _isActiveFilter,
                  label: const Text('Status'),
                  onSelected: (val) => setState(() => _isActiveFilter = val),
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: null, label: 'All Statuses'),
                    DropdownMenuEntry(value: true, label: 'Active'),
                    DropdownMenuEntry(value: false, label: 'Inactive'),
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
