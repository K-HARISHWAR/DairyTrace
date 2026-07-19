import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../authentication/data/models/profile_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(supabaseServiceProvider).client);
});

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  Future<List<ProfileModel>> getAllUsers() async {
    final data = await _client.from(DatabaseTables.profiles).select().order('created_at', ascending: false);
    return (data as List).map((e) => ProfileModel.fromJson(e)).toList();
  }

  Future<ProfileModel> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
    String? collectionCentreId,
    String? distributorId,
  }) async {
    // Calls the admin-create-user edge function
    final response = await _client.functions.invoke('admin-create-user', body: {
      'email': email,
      'password': password,
      'full_name': fullName,
      'role': role,
      'phone': phone,
      'collection_centre_id': collectionCentreId,
      'distributor_organisation_id': distributorId,
    });
    
    if (response.status != 200) {
      throw Exception('Failed to create user: ${response.data}');
    }

    // Now fetch the newly created profile using email (since we don't have the auth.users ID locally)
    final profileData = await _client.from(DatabaseTables.profiles).select().eq('email', email).single();
    return ProfileModel.fromJson(profileData);
  }
}
