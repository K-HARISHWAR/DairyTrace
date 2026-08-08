import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/batch_model.dart';
import '../../../../core/enums/batch_stage.dart';
import '../../../../core/enums/batch_status.dart';
import '../../../../core/utils/repository_helper.dart';

final batchRepositoryProvider = Provider<BatchRepository>((ref) {
  return BatchRepository(ref.watch(supabaseServiceProvider).client);
});

class BatchRepository with RepositoryHelper {
  final SupabaseClient _client;

  BatchRepository(this._client);

  Future<List<BatchModel>> getBatches({
    String? collectionCentreId,
    BatchStatus? status,
  }) async {
    return executeDb(() async {
      var query = _client
          .from(DatabaseTables.batches)
          .select(
            'id, batch_code, public_token, farm_id, collection_centre_id, quantity_litres, collection_time, current_stage, overall_status, quality_status, created_by, created_at, updated_at',
          );

      if (collectionCentreId != null) {
        query = query.eq('collection_centre_id', collectionCentreId);
      }
      if (status != null) {
        query = query.eq('overall_status', status.value);
      }

      final data = await query.order('created_at', ascending: false);
      return (data as List).map((e) => BatchModel.fromJson(e)).toList();
    });
  }

  Future<List<BatchModel>> getBatchesPaginated({
    String? collectionCentreId,
    String? searchQuery,
    BatchStage? stageFilter,
    BatchStatus? statusFilter,
    int page = 1,
    int pageSize = 20,
  }) async {
    return executeDb(() async {
      var query = _client
          .from(DatabaseTables.batches)
          .select(
            'id, batch_code, public_token, farm_id, collection_centre_id, quantity_litres, collection_time, current_stage, overall_status, quality_status, created_by, created_at, updated_at',
          );

      if (collectionCentreId != null) {
        query = query.eq('collection_centre_id', collectionCentreId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('batch_code', '%$searchQuery%');
      }
      if (stageFilter != null) {
        query = query.eq('current_stage', stageFilter.value);
      }
      if (statusFilter != null) {
        query = query.eq('overall_status', statusFilter.value);
      }

      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;

      final data = await query
          .range(from, to)
          .order('created_at', ascending: false);
      return (data as List).map((e) => BatchModel.fromJson(e)).toList();
    });
  }

  Future<BatchModel> getBatchById(String id) async {
    return executeDb(() async {
      final data = await _client
          .from(DatabaseTables.batches)
          .select('*, farms(*), collection_centres(*)')
          .eq('id', id)
          .single();
      return BatchModel.fromJson(data);
    });
  }

  Future<BatchModel> getBatchByPublicToken(String token) async {
    return executeDb(() async {
      final data = await _client
          .from(DatabaseTables.batches)
          .select('*, farms(*), collection_centres(*)')
          .eq('public_token', token)
          .single();
      return BatchModel.fromJson(data);
    });
  }

  Future<BatchModel> createBatchTransaction({
    required String farmId,
    required String collectionCentreId,
    required double quantityLitres,
    required DateTime collectionTime,
    required double fatPercentage,
    required double snfPercentage,
    required double temperature,
    required bool purityPassed,
    String? qualityRemarks,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser!.id;

    // Use RPC if we wanted a true transaction, but Supabase JS/Dart client can't do multiple statements in one transaction easily without an RPC.
    // However, the PRD says: "Perform database writes transactionally where possible".
    // We will do them sequentially. If batch creation succeeds, it exists.
    // The quality trigger will update it automatically when the quality_check is inserted.

    final batchData = await _client
        .from(DatabaseTables.batches)
        .insert({
          'farm_id': farmId,
          'collection_centre_id': collectionCentreId,
          'quantity_litres': quantityLitres,
          'collection_time': collectionTime.toIso8601String(),
          'created_by': userId,
          'notes': notes,
          'current_stage': BatchStage.collection.value,
          'overall_status': BatchStatus.inProgress.value,
          'quality_status': 'pending', // Will be updated by trigger
        })
        .select()
        .single();

    final batchId = batchData['id'] as String;

    // Insert tracking event
    await _client.from(DatabaseTables.trackingEvents).insert({
      'batch_id': batchId,
      'stage': BatchStage.collection.value,
      'event_type': 'batch_created',
      'status': 'registered',
      'created_by': userId,
      'remarks': 'Batch collected from farm',
    });

    // Insert quality check (this triggers evaluate_quality() in DB)
    await _client.from(DatabaseTables.qualityChecks).insert({
      'batch_id': batchId,
      'checkpoint': 'collection',
      'fat_percentage': fatPercentage,
      'snf_percentage': snfPercentage,
      'temperature_c': temperature,
      'purity_passed': purityPassed,
      'checked_by': userId,
      'remarks': qualityRemarks,
    });

    // Re-fetch the batch to get the updated status from the trigger
    return await getBatchById(batchId);
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
    return executeDb(() async {
      final userId = _client.auth.currentUser!.id;

      // Update batch stage
      await _client
          .from(DatabaseTables.batches)
          .update({'current_stage': newStage.value})
          .eq('id', batchId);

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
    });
  }
}
