import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/dairy_trace_app.dart';
import 'core/config/supabase_config.dart';
import 'core/services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SupabaseConfig.validate();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.publishableKey,
  );

  // Initialize notifications safely. Permission is requested lazily later.
  await LocalNotificationService().initialize();

  runApp(
    const ProviderScope(
      child: DairyTraceApp(),
    ),
  );
}
