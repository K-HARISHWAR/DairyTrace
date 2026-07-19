import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/batch_model.dart';
import '../../../../core/enums/batch_stage.dart';
import '../../../../core/enums/batch_status.dart';

final batchRepositoryProvider = Provider<BatchRepository>((ref) {
  return BatchRepository(ref.watch(supabaseServiceProvider).client);
});

class BatchRepository {
  final SupabaseClient _client;

  BatchRepository(this._client);

  Future<List<BatchModel>> getBatches({String? collectionCentreId, BatchStatus? status}) async {
    var query = _client.from(DatabaseTables.batches).select();
    
    if (collectionCentreId != null) {
      query = query.eq('collection_centre_id', collectionCentreId);
    }
    if (status != null) {
      query = query.eq('overall_status', status.value);
    }
    
    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => BatchModel.fromJson(e)).toList();
  }

  Future<BatchModel> getBatchById(String id) async {
    final data = await _client.from(DatabaseTables.batches).select().eq('id', id).single();
    return BatchModel.fromJson(data);
  }

  Future<BatchModel> getBatchByPublicToken(String token) async {
    final data = await _client.from(DatabaseTables.batches).select().eq('public_token', token).single();
    return BatchModel.fromJson(data);
  }

  Future<BatchModel> createBatch({
    required String farmId,
    required String collectionCentreId,
    required double quantityLitres,
    required DateTime collectionTime,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser!.id;

    final data = await _client.from(DatabaseTables.batches).insert({
      'farm_id': farmId,
      'collection_centre_id': collectionCentreId,
      'quantity_litres': quantityLitres,
      'collection_time': collectionTime.toIso8601String(),
      'created_by': userId,
      'notes': notes,
    }).select().single();

    final batch = BatchModel.fromJson(data);

    // Initial tracking event
    await _client.from(DatabaseTables.trackingEvents).insert({
      'batch_id': batch.id,
      'stage': BatchStage.collection.value,
      'event_type': 'batch_created',
      'status': 'registered',
      'created_by': userId,
      'remarks': 'Batch collected from farm',
    });

    return batch;
  }

  Future<void> updateBatchStage({
    required String batchId,
    required BatchStage newStage,
    required String eventType,
    required String status,
    String? locationName,
    double? latitude,
    double? longitude,
    String? remarks,
  }) async {
    final userId = _client.auth.currentUser!.id;
    
    // Update batch stage
    await _client.from(DatabaseTables.batches).update({
      'current_stage': newStage.value,
    }).eq('id', batchId);

    // Record journey event
    await _client.from(DatabaseTables.trackingEvents).insert({
      'batch_id': batchId,
      'stage': newStage.value,
      'event_type': eventType,
      'status': status,
      'created_by': userId,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'remarks': remarks,
    });
  }
}
