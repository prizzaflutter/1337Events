import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle notification tapped in background
  debugPrint('🔔 Notification clicked in background: ${notificationResponse.payload}');

  // You can parse the payload and store it in shared preferences
  // to be handled when the app is launched
  if (notificationResponse.payload != null) {
    try {
      final payloadData = jsonDecode(notificationResponse.payload!);
      // Process payload data
      debugPrint('📱 Payload data: $payloadData');

      // Store in shared preferences for app launch handling
      // SharedPreferences.getInstance().then((prefs) {
      //   prefs.setString('notification_payload', notificationResponse.payload!);
      // });
    } catch (e) {
      debugPrint('❌ Error parsing background notification payload: $e');
    }
  }
}

class BackgroundNotificationHandler {
  static final BackgroundNotificationHandler _instance = BackgroundNotificationHandler._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory BackgroundNotificationHandler() {
    return _instance;
  }

  BackgroundNotificationHandler._internal();

  Future<void> initialize() async {
    await _configureLocalTimeZone();
    await _createNotificationChannels();
    await _initializeNotifications();
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('✅ Timezone configured: $timeZoneName');
    } catch (e) {
      debugPrint('❌ Error configuring timezone: $e');
    }
  }

  // Create multiple notification channels for different types
  Future<void> _createNotificationChannels() async {
    // High importance channel for urgent notifications
    AndroidNotificationChannel highImportanceChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Channel for urgent notifications with maximum sound and vibration',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Colors.red,
      sound: const RawResourceAndroidNotificationSound('notification_sound'), // Custom sound
    );

    // Default channel for regular notifications
    const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
      'default_channel',
      'Default Notifications',
      description: 'Channel for regular notifications with sound and vibration',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Colors.blue,
    );

    // Silent channel for low-priority notifications
    const AndroidNotificationChannel silentChannel = AndroidNotificationChannel(
      'silent_channel',
      'Silent Notifications',
      description: 'Channel for silent notifications',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      enableLights: false,
    );

    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(highImportanceChannel);
      await androidImplementation.createNotificationChannel(defaultChannel);
      await androidImplementation.createNotificationChannel(silentChannel);
      debugPrint('✅ Notification channels created successfully');
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true, // For critical alerts
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    debugPrint('✅ Background notification handler initialized');
  }

  // Enhanced notification with sound, vibration, and visual effects
  Future<void> showNotificationFromBackground(
      String title,
      String body,
      Map<String, dynamic>? additionalData, {
        NotificationPriority priority = NotificationPriority.high,
        String? customSound,
        List<int>? vibrationPattern,
        Color? ledColor,
      }) async {

    String channelId;
    String channelName;
    Importance importance;
    Priority androidPriority;

    // Select channel and settings based on priority
    switch (priority) {
      case NotificationPriority.urgent:
        channelId = 'high_importance_channel';
        channelName = 'High Importance Notifications';
        importance = Importance.max;
        androidPriority = Priority.high;
        break;
      case NotificationPriority.silent:
        channelId = 'silent_channel';
        channelName = 'Silent Notifications';
        importance = Importance.low;
        androidPriority = Priority.low;
        break;
      default:
        channelId = 'default_channel';
        channelName = 'Default Notifications';
        importance = Importance.high;
        androidPriority = Priority.high;
    }

    // Enhanced Android notification settings
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Enhanced notifications with sound and effects',
      importance: importance,
      priority: androidPriority,
      showWhen: true,
      playSound: priority != NotificationPriority.silent,
      enableVibration: priority != NotificationPriority.silent,
      enableLights: priority != NotificationPriority.silent,
      color: ledColor ?? Colors.blue,
      ledColor: ledColor ?? Colors.blue,
      ledOnMs: 1000,
      ledOffMs: 500,
      ticker: title, // Shows in status bar
      autoCancel: true,
      fullScreenIntent: priority == NotificationPriority.urgent, // For urgent notifications
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      sound: customSound != null
          ? RawResourceAndroidNotificationSound(customSound)
          : null,
      // Additional visual enhancements
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: 'New message',
        htmlFormatSummaryText: true,
      ),
    );

    // Enhanced iOS notification settings
    DarwinNotificationDetails iOSNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: priority != NotificationPriority.silent,
      sound: customSound ?? 'default',
      badgeNumber: 1,
      threadIdentifier: 'background_notifications',
      categoryIdentifier: 'message_category',
      interruptionLevel: priority == NotificationPriority.urgent
          ? InterruptionLevel.critical
          : InterruptionLevel.active,
      subtitle: priority == NotificationPriority.urgent ? 'Urgent' : null,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    String? payload;
    if (additionalData != null) {
      payload = jsonEncode(additionalData);
    }

    try {
      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      debugPrint('✅ Enhanced background notification shown: $title');
    } catch (e) {
      debugPrint('❌ Error showing background notification: $e');
    }
  }

  // Method for urgent notifications with maximum impact
  Future<void> showUrgentNotification(
      String title,
      String body,
      Map<String, dynamic>? additionalData,
      ) async {
    await showNotificationFromBackground(
      title,
      body,
      additionalData,
      priority: NotificationPriority.urgent,
      vibrationPattern: [0, 1000, 500, 1000, 500, 1000], // Intense vibration
      ledColor: Colors.red,
    );
  }

  // Method for silent notifications
  Future<void> showSilentNotification(
      String title,
      String body,
      Map<String, dynamic>? additionalData,
      ) async {
    await showNotificationFromBackground(
      title,
      body,
      additionalData,
      priority: NotificationPriority.silent,
    );
  }

  // Method to schedule a delayed notification
  Future<void> scheduleNotification(
      int id,
      String title,
      String body,
      DateTime scheduledDate,
      Map<String, dynamic>? additionalData,
      ) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      channelDescription: 'Scheduled notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    const DarwinNotificationDetails iOSNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    String? payload;
    if (additionalData != null) {
      payload = jsonEncode(additionalData);
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // Method to test different notification types
  Future<void> testNotifications() async {
    await Future.delayed(const Duration(seconds: 2));
    await showNotificationFromBackground(
      'Test Normal',
      'This is a normal notification with sound and vibration',
      {'type': 'test', 'priority': 'normal'},
    );

    await Future.delayed(const Duration(seconds: 5));
    await showUrgentNotification(
      'Test Urgent',
      'This is an urgent notification with intense effects!',
      {'type': 'test', 'priority': 'urgent'},
    );

    await Future.delayed(const Duration(seconds: 8));
    await showSilentNotification(
      'Test Silent',
      'This is a silent notification',
      {'type': 'test', 'priority': 'silent'},
    );
  }

}

// Enum for notification priorities
enum NotificationPriority {
  silent,
  low,
  normal,
  high,
  urgent,
}