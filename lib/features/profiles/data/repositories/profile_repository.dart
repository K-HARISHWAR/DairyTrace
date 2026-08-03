import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/repository_helper.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseServiceProvider).client);
});

class ProfileRepository with RepositoryHelper {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<Map<String, dynamic>> getProfile(String userId) async {
    return executeDb(() async {
      final data = await _client
          .from(DatabaseTables.profiles)
          .select(
            'id, full_name, email, role, collection_centre_id, distributor_organisation_id',
          )
          .eq('id', userId)
          .single();
      return data;
    });
  }
}
