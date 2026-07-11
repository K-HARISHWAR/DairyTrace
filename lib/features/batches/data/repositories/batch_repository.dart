import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/batch_model.dart';
import '../../../../core/enums/batch_stage.dart';
import '../../../../core/enums/quality_result.dart';

final batchRepositoryProvider = Provider<BatchRepository>((ref) {
  return BatchRepository(ref.watch(supabaseServiceProvider).client);
});

class BatchRepository {
  final SupabaseClient _client;

  BatchRepository(this._client);

  Future<List<BatchModel>> getBatches() async {
    final data = await _client
        .from(DatabaseTables.batches)
        .select()
        .order('created_at', ascending: false);
    
    return (data as List).map((e) => BatchModel.fromJson(e)).toList();
  }

  Future<BatchModel> createBatch({
    required String farmId,
    required double quantityLiters,
    required double temperature,
    required double fat,
    required double snf,
    required QualityResult qualityResult,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final stage = qualityResult == QualityResult.pass ? BatchStage.accepted : BatchStage.rejected;

    final data = await _client.from(DatabaseTables.batches).insert({
      'farm_id': farmId,
      'created_by': userId,
      'quantity_liters': quantityLiters,
      'temperature_celsius': temperature,
      'fat_percentage': fat,
      'snf_percentage': snf,
      'quality_result': qualityResult.value,
      'stage': stage.value,
      'notes': 'Initial quality check performed.',
    }).select().single();

    final batch = BatchModel.fromJson(data);

    // Record initial journey
    await _client.from(DatabaseTables.batchJourneys).insert({
      'batch_id': batch.id,
      'stage': stage.value,
      'recorded_by': userId,
      'notes': 'Batch registered at Collection Center',
    });

    return batch;
  }

  Future<void> updateBatchStage({
    required String batchId,
    required BatchStage newStage,
    double? lat,
    double? lng,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser!.id;
    
    // Update batch stage
    await _client.from(DatabaseTables.batches).update({
      'stage': newStage.value,
    }).eq('id', batchId);

    // Record journey
    await _client.from(DatabaseTables.batchJourneys).insert({
      'batch_id': batchId,
      'stage': newStage.value,
      'recorded_by': userId,
      'location_lat': lat,
      'location_lng': lng,
      'notes': notes,
    });
  }
}
