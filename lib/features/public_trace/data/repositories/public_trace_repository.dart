import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

final publicTraceRepositoryProvider = Provider<PublicTraceRepository>((ref) {
  return PublicTraceRepository(ref.watch(supabaseServiceProvider).client);
});

class PublicTraceRepository {
  final SupabaseClient _client;

  PublicTraceRepository(this._client);

  Future<Map<String, dynamic>?> getPublicBatchTrace(String publicToken) async {
    final response = await _client.rpc('get_public_batch_trace', params: {
      'p_public_token': publicToken,
    });
    
    if (response == null) return null;
    return response as Map<String, dynamic>;
  }
}
