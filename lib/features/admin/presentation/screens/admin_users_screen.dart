import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/admin_users_provider.dart';
import '../../data/repositories/admin_repository.dart';
import '../../../../core/enums/user_role.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _searchQuery = '';
  UserRole? _roleFilter;
  bool? _statusFilter; // null = all, true = active, false = inactive

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.pushNamed('admin_create_user');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(context),
          Expanded(
            child: usersAsync.when(
              data: (users) {
                // Apply filters
                var filtered = users.where((u) {
                  final matchesSearch = u.fullName.toLowerCase().contains(_searchQuery) || u.email.toLowerCase().contains(_searchQuery);
                  final matchesRole = _roleFilter == null || u.role == _roleFilter;
                  final matchesStatus = _statusFilter == null || u.isActive == _statusFilter;
                  return matchesSearch && matchesRole && matchesStatus;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No users match the criteria.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(user.fullName[0].toUpperCase()),
                        ),
                        title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${user.email} • ${user.role.value}'),
                        trailing: Switch(
                          value: user.isActive,
                          activeColor: Colors.green,
                          onChanged: user.role == UserRole.admin ? null : (val) async {
                            try {
                              await ref.read(adminRepositoryProvider).updateUserStatus(user.id, val);
                              ref.invalidate(adminUsersProvider); // Refresh list
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
                              }
                            }
                          },
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

  Widget _buildFilters(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search name or email...',
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
                DropdownMenu<UserRole?>(
                  initialSelection: _roleFilter,
                  label: const Text('Role'),
                  onSelected: (val) => setState(() => _roleFilter = val),
                  dropdownMenuEntries: [
                    const DropdownMenuEntry(value: null, label: 'All Roles'),
                    ...UserRole.values.map((e) => DropdownMenuEntry(value: e, label: e.value)),
                  ],
                ),
                const SizedBox(width: 12),
                DropdownMenu<bool?>(
                  initialSelection: _statusFilter,
                  label: const Text('Status'),
                  onSelected: (val) => setState(() => _statusFilter = val),
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
