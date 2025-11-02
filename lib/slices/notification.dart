// lib/slices/notification.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  // Singleton boilerplate
  NotificationService._privateConstructor();
  static final NotificationService _instance =
      NotificationService._privateConstructor();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Call once at app start
  Future<void> init() async {
    // Timezone setup
    initializeTimeZones();
    setLocalLocation(getLocation('America/Toronto'));

    // Android & iOS settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin
    await _plugin.initialize(initSettings);

    // Request Android notification permission
    final granted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    if (granted != true) {
      debugPrint('Notification permission not granted');
    }
  }

  /// Show a notification immediately
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_notification_channel_id',
        'Instant Notifications',
        channelDescription: 'Instant notification channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(id, title, body, details);
  }

  /// Schedule a reminder 3 seconds from now (repeat daily)
  Future<void> scheduleReminder({
    required int id,
    required String title,
    String? body,
  }) async {
    final now = TZDateTime.now(local);
    final scheduledDate = now.add(const Duration(seconds: 3));

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder_channel_id',
        'Daily Reminders',
        channelDescription: 'Reminder to complete daily habits',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }
}
