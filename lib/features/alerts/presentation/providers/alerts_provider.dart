import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../models/alert_model.dart';
import '../repositories/alert_repository.dart';

final alertsProvider = StreamProvider<List<AlertModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  
  // We should ideally listen to alerts for the user's specific collection centre.
  // For now, we'll assume the scope is filtered by the RLS policies in Supabase, 
  // or we pass the specific centre ID if available in the profile.
  // We'll just listen to all unresolved alerts the user has access to via RLS.
  final stream = ref.watch(alertRepositoryProvider).watchAlerts();

  return stream.map((dataList) {
    final alerts = dataList.map((e) => AlertModel.fromJson(e)).toList();
    
    // Sort so newest is first
    alerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Check for new critical/high alerts to notify
    for (final alert in alerts) {
      if (!alert.isResolved && (alert.severity == AlertSeverity.critical || alert.severity == AlertSeverity.high)) {
        LocalNotificationService().showNotification(
          id: alert.id,
          title: alert.title,
          body: alert.message,
        );
      }
    }

    return alerts;
  });
});
