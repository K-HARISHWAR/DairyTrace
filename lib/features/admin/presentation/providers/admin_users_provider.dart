import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/data/models/profile_model.dart';
import '../../data/repositories/admin_repository.dart';

final adminUsersProvider = FutureProvider.autoDispose<List<ProfileModel>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getAllUsers();
});

final activeCentresProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return await ref.watch(adminRepositoryProvider).getActiveCentres();
});

final activeDistributorsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return await ref.watch(adminRepositoryProvider).getActiveDistributors();
});
