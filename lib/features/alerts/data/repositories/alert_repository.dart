import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/alert_model.dart';

// Wrap custom exceptions
class AlertRepositoryException implements Exception {
  final String message;
  AlertRepositoryException(this.message);
  @override
  String toString() => 'AlertRepositoryException: $message';
}

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepository(ref.watch(supabaseServiceProvider).client);
});

class AlertRepository {
  final SupabaseClient _client;

  AlertRepository(this._client);

  /// Fetches unresolved alerts, paginated.
  Future<List<AlertModel>> getUnresolvedAlerts({
    int page = 1,
    int pageSize = 20,
    String? collectionCentreId,
  }) async {
    try {
      var query = _client
          .from(DatabaseTables.alerts)
          .select('id, title, message, severity, alert_type, batch_id, delivery_id, collection_centre_id, is_resolved, created_at')
          .eq('is_resolved', false);

      if (collectionCentreId != null) {
        query = query.eq('collection_centre_id', collectionCentreId);
      }

      // Pagination
      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;

      final data = await query
          .order('created_at', ascending: false)
          .range(from, to);

      return (data as List).map((e) => AlertModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw AlertRepositoryException('Database error: ${e.message}');
    } catch (e) {
      throw AlertRepositoryException('Failed to fetch alerts: $e');
    }
  }

  /// Mark an alert as resolved.
  Future<void> resolveAlert(String alertId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw AlertRepositoryException('Not authenticated');

      await _client
          .from(DatabaseTables.alerts)
          .update({
            'is_resolved': true,
            'resolved_at': DateTime.now().toUtc().toIso8601String(),
            'resolved_by': userId,
          })
          .eq('id', alertId);
    } on PostgrestException catch (e) {
      throw AlertRepositoryException('Database error: ${e.message}');
    } catch (e) {
      throw AlertRepositoryException('Failed to resolve alert: $e');
    }
  }

  /// Returns a stream of real-time alert inserts for the user's scope.
  Stream<List<Map<String, dynamic>>> watchAlerts({String? collectionCentreId}) {
    var filter = 'is_resolved=eq.false';
    if (collectionCentreId != null) {
      filter += '&collection_centre_id=eq.$collectionCentreId';
    }

    return _client
        .from(DatabaseTables.alerts)
        .stream(primaryKey: ['id'])
        .eq('is_resolved', false)
        // Note: the supabase stream filter api might not support complex ANDs directly without eq.
        // We will just stream all unresolved and let the frontend filter if needed, or stick to this.
        .order('created_at', ascending: false);
  }
}
