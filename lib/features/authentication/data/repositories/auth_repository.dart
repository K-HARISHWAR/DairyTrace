import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseServiceProvider).client);
});

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Future<UserModel> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed');
    }

    return _fetchUserProfile(response.user!.id);
  }

  Future<UserModel> _fetchUserProfile(String userId) async {
    final data = await _client
        .from(DatabaseTables.users)
        .select()
        .eq('id', userId)
        .single();
    
    return UserModel.fromJson(data);
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchUserProfile(user.id);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
