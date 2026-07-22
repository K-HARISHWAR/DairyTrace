import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums/user_role.dart';
import '../../data/repositories/admin_repository.dart';
import '../providers/admin_users_provider.dart';

class AdminCreateUserScreen extends ConsumerStatefulWidget {
  const AdminCreateUserScreen({super.key});

  @override
  ConsumerState<AdminCreateUserScreen> createState() => _AdminCreateUserScreenState();
}

class _AdminCreateUserScreenState extends ConsumerState<AdminCreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  UserRole _selectedRole = UserRole.collectionStaff;
  String? _selectedCentreId;
  String? _selectedDistributorId;
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(adminRepositoryProvider).createUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        role: _selectedRole.value,
        phone: _phoneController.text.trim(),
        collectionCentreId: _selectedRole == UserRole.collectionStaff ? _selectedCentreId : null,
        distributorId: _selectedRole == UserRole.distributor ? _selectedDistributorId : null,
      );
      
      // Refresh user list
      ref.invalidate(adminUsersProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User created successfully!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New User')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Temporary Password'),
                obscureText: true,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number (Optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: UserRole.values
                    .where((r) => r != UserRole.customer) // Can't create customer here
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.value.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              if (_selectedRole == UserRole.collectionStaff) ...[
                const SizedBox(height: 16),
                ref.watch(activeCentresProvider).when(
                  data: (centres) => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Collection Centre'),
                    items: centres.map((c) => DropdownMenuItem<String>(
                      value: c['id'] as String,
                      child: Text(c['name'] as String),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedCentreId = val),
                    validator: (v) => v == null ? 'Please select a centre' : null,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error loading centres: $e'),
                ),
              ],
              if (_selectedRole == UserRole.distributor) ...[
                const SizedBox(height: 16),
                ref.watch(activeDistributorsProvider).when(
                  data: (distributors) => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Distributor Organisation'),
                    items: distributors.map((d) => DropdownMenuItem<String>(
                      value: d['id'] as String,
                      child: Text(d['name'] as String),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedDistributorId = val),
                    validator: (v) => v == null ? 'Please select an organisation' : null,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error loading distributors: $e'),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
