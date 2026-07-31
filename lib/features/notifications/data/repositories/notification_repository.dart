import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/repository_helper.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(supabaseServiceProvider).client);
});

class NotificationRepository with RepositoryHelper {
  final SupabaseClient _client;

  NotificationRepository(this._client);

  Future<void> markAsRead(String notificationId) async {
    return executeDb(() async {
      await _client
          .from(DatabaseTables.appNotifications)
          .update({'is_read': true})
          .eq('id', notificationId);
    });
  }
}
