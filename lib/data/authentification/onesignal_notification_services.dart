import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalNotificationService {
  static final OneSignalNotificationService _instance = OneSignalNotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory OneSignalNotificationService() {
    return _instance;
  }

  OneSignalNotificationService._internal();

  Future<void> initOneSignalAndLocalNotifications() async {
    // Initialize Flutter Local Notifications
    await _initializeLocalNotifications();

    // Request notification permission
    await _requestNotificationPermissions();

    // Initialize OneSignal
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize('6486fc75-cf18-49fb-9d43-bca5c7990f54');
    OneSignal.Notifications.requestPermission(true);

    // Configure OneSignal handlers
    _setupOneSignalHandlers();
  }

  Future<void> _initializeLocalNotifications() async {
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
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    debugPrint('Notification clicked: ${notificationResponse.payload}');
    // Handle notification tap here - can navigate to specific screen based on payload
  }

  // This needs to be a top-level function
  static void notificationTapBackground(NotificationResponse notificationResponse) {
    // Handle notification tap in background
    debugPrint('Notification clicked in background: ${notificationResponse.payload}');
  }

  Future<void> _requestNotificationPermissions() async {
    // Request Android permissions
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Request iOS permissions
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _setupOneSignalHandlers() {
    // Handle foreground notifications
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint("OneSignal Notification Received: ${event.notification.title}");

      // Convert OneSignal notification to Local Notification
      _showLocalNotification(event.notification);

      // Complete the OneSignal notification (won't show OneSignal's default UI)
      event.preventDefault();
    });

    // Handle notification clicked
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('OneSignal Notification Clicked: ${event.notification.title}');
      // You can add specific navigation logic here if needed
    });
  }

  Future<void> _showLocalNotification(OSNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'onesignal_channel',
      'OneSignal Notifications',
      channelDescription: 'Channel for OneSignal push notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Create payload string from additional data if available
    String? payload;
    if (notification.additionalData != null) {
      payload = notification.additionalData.toString();
    }

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Method to handle terminated state notifications
  Future<void> checkForInitialNotification() async {
    // Check if app was opened from a notification
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails != null &&
        notificationAppLaunchDetails.didNotificationLaunchApp &&
        notificationAppLaunchDetails.notificationResponse != null) {

      final payload = notificationAppLaunchDetails.notificationResponse!.payload;
      debugPrint('App launched from notification with payload: $payload');

      // Handle the notification payload here
      // You can navigate to a specific screen based on the payload
    }
  }
}