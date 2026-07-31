import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // Track recently shown notifications by deduplication_key or ID to avoid duplicates
  final Set<String> _recentlyShown = {};

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Request permission lazily later, so set request functions to false here
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Navigate to alerts screen based on payload
    // You would typically use a navigation key or router setup here.
    // For now, this is a placeholder. 
    print('Notification tapped: ${response.payload}');
  }

  Future<void> requestPermissions() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> showNotification({
    required String id, // DB alert ID
    required String title,
    required String body,
    String? payload,
  }) async {
    // Avoid duplicates
    if (_recentlyShown.contains(id)) return;
    _recentlyShown.add(id);

    // Keep memory clean
    if (_recentlyShown.length > 100) {
      _recentlyShown.clear();
      _recentlyShown.add(id);
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'dairytrace_alerts',
      'DairyTrace Alerts',
      channelDescription: 'High priority alerts for DairyTrace operations',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Use a random int for notification ID since FlutterLocalNotifications needs an int, but DB ID is UUID
    final notifId = Random().nextInt(1000000);

    await _flutterLocalNotificationsPlugin.show(
      notifId,
      title,
      body,
      platformChannelSpecifics,
      payload: payload ?? id,
    );
  }
}
