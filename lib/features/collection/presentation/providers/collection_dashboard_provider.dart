import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class CollectionDashboardStatsNotifier extends AutoDisposeAsyncNotifier<Map<String, dynamic>> {
  @override
  FutureOr<Map<String, dynamic>> build() async {
    return _fetchStats();
  }

  Future<Map<String, dynamic>> _fetchStats() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null || user.collectionCentreId == null) {
      throw Exception('No collection centre assigned to this user');
    }
    
    final client = ref.watch(supabaseServiceProvider).client;
    final response = await client.rpc(
      'get_collection_dashboard_stats',
      params: {'p_centre_id': user.collectionCentreId},
    );
    
    return response as Map<String, dynamic>;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final stats = await _fetchStats();
      state = AsyncData(stats);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final collectionDashboardStatsProvider = AutoDisposeAsyncNotifierProvider<CollectionDashboardStatsNotifier, Map<String, dynamic>>(CollectionDashboardStatsNotifier.new);
