import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

final collectionDashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
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
});
