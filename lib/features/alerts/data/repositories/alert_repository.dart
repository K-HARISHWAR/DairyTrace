import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/alert_model.dart';

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepository(ref.watch(supabaseServiceProvider).client);
});

class AlertRepository {
  final SupabaseClient _client;

  AlertRepository(this._client);

  Future<List<AlertModel>> getAlerts({String? collectionCentreId, bool? isResolved}) async {
    var query = _client.from(DatabaseTables.alerts).select();
    
    if (collectionCentreId != null) {
      query = query.eq('collection_centre_id', collectionCentreId);
    }
    
    if (isResolved != null) {
      query = query.eq('is_resolved', isResolved);
    }
    
    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => AlertModel.fromJson(e)).toList();
  }

  Future<AlertModel> resolveAlert(String alertId) async {
    final userId = _client.auth.currentUser!.id;
    
    final data = await _client.from(DatabaseTables.alerts).update({
      'is_resolved': true,
      'resolved_at': DateTime.now().toIso8601String(),
      'resolved_by': userId,
    }).eq('id', alertId).select().single();

    return AlertModel.fromJson(data);
  }
}
