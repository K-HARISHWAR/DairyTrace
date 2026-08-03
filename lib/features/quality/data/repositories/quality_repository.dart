import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/quality_check_model.dart';

final qualityRepositoryProvider = Provider<QualityRepository>((ref) {
  return QualityRepository(ref.watch(supabaseServiceProvider).client);
});

class QualityRepository {
  final SupabaseClient _client;

  QualityRepository(this._client);

  Future<List<QualityCheckModel>> getChecksForBatch(String batchId) async {
    final data = await _client
        .from(DatabaseTables.qualityChecks)
        .select()
        .eq('batch_id', batchId)
        .order('checked_at', ascending: false);

    return (data as List).map((e) => QualityCheckModel.fromJson(e)).toList();
  }

  Future<QualityCheckModel> submitQualityCheck({
    required String batchId,
    required String checkpoint,
    double? fatPercentage,
    double? snfPercentage,
    double? temperatureC,
    bool? purityPassed,
    String? manualResult,
    String? remarks,
  }) async {
    final userId = _client.auth.currentUser!.id;

    final data = await _client
        .from(DatabaseTables.qualityChecks)
        .insert({
          'batch_id': batchId,
          'checkpoint': checkpoint,
          'fat_percentage': fatPercentage,
          'snf_percentage': snfPercentage,
          'temperature_c': temperatureC,
          'purity_passed': purityPassed,
          'manual_result': manualResult,
          'remarks': remarks,
          'checked_by': userId,
        })
        .select()
        .single();

    return QualityCheckModel.fromJson(data);
  }
}
