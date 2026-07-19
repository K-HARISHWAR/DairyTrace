import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/tracking_event_model.dart';

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepository(ref.watch(supabaseServiceProvider).client);
});

class TrackingRepository {
  final SupabaseClient _client;

  TrackingRepository(this._client);

  Future<List<TrackingEventModel>> getEventsForBatch(String batchId) async {
    final data = await _client
        .from(DatabaseTables.trackingEvents)
        .select()
        .eq('batch_id', batchId)
        .order('occurred_at', ascending: false);
        
    return (data as List).map((e) => TrackingEventModel.fromJson(e)).toList();
  }

  Future<TrackingEventModel> addTrackingEvent({
    required String batchId,
    required String stage,
    required String eventType,
    required String status,
    String? locationName,
    double? latitude,
    double? longitude,
    String? remarks,
  }) async {
    final userId = _client.auth.currentUser!.id;
    
    final data = await _client.from(DatabaseTables.trackingEvents).insert({
      'batch_id': batchId,
      'stage': stage,
      'event_type': eventType,
      'status': status,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'remarks': remarks,
      'created_by': userId,
    }).select().single();

    return TrackingEventModel.fromJson(data);
  }
}
