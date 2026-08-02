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

  Future<List<ProfileModel>> getUsersPaginated({
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  }) async {
    var query = _client.from(DatabaseTables.profiles).select();
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('full_name.ilike.%$searchQuery%,email.ilike.%$searchQuery%');
    }
    
    final from = (page - 1) * pageSize;
    final to = from + pageSize - 1;
    
    final data = await query.range(from, to).order('created_at', ascending: false);
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

  Future<void> updateUserStatus(String userId, bool isActive) async {
    await _client.from(DatabaseTables.profiles).update({'is_active': isActive}).eq('id', userId);
  }

  Future<List<Map<String, dynamic>>> getActiveCentres() async {
    final data = await _client.from('collection_centres').select('id, name');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getActiveDistributors() async {
    final data = await _client.from('distributor_organisations').select('id, name');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _client.rpc('get_admin_dashboard_stats');
    return response as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getDailyCollectionVolume(int days) async {
    final response = await _client.rpc('get_daily_collection_volume', params: {'days': days});
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getRejectionTrend(int days) async {
    final response = await _client.rpc('get_rejection_trend', params: {'days': days});
    return List<Map<String, dynamic>>.from(response);
  }
}
