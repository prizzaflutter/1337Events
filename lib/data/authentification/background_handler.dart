
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
  debugPrint('Notification clicked in background: ${notificationResponse.payload}');

  // You can parse the payload and store it in shared preferences
  // to be handled when the app is launched
  if (notificationResponse.payload != null) {
    final payloadData = jsonDecode(notificationResponse.payload!);
    // Process payload data
    debugPrint('Payload data: $payloadData');
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
    await _initializeNotifications();
  }

  Future<void> _configureLocalTimeZone() async {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> showNotificationFromBackground(String title, String body, Map<String, dynamic>? additionalData) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'onesignal_channel',
      'OneSignal Notifications',
      channelDescription: 'Channel for OneSignal push notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    String? payload;
    if (additionalData != null) {
      payload = jsonEncode(additionalData);
    }

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}