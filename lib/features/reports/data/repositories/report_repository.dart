import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/repository_helper.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.watch(supabaseServiceProvider).client);
});

class ReportRepository with RepositoryHelper {
  final SupabaseClient _client;

  ReportRepository(this._client);

  Future<List<Map<String, dynamic>>> getDailyVolume(int days) async {
    return executeDb(() async {
      // In a real app, you'd call a dedicated RPC for aggregation
      // We will leave this as a stub that the dashboard provider uses or mocks
      return [];
    });
  }
}
