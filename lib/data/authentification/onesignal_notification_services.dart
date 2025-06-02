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
    try {
      // Initialize Flutter Local Notifications first
      await _initializeLocalNotifications();

      // Request notification permission
      await _requestNotificationPermissions();

      // Initialize OneSignal
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize('6486fc75-cf18-49fb-9d43-bca5c7990f54');

      // Request OneSignal permissions explicitly
      await OneSignal.Notifications.requestPermission(true);

      // Configure OneSignal handlers
      _setupOneSignalHandlers();

      debugPrint('✅ OneSignal and Local Notifications initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    // Create notification channel for Android
    await _createNotificationChannel();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true, // For important notifications
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

  // Create a high-priority notification channel for Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel name
      description: 'This channel is used for important notifications with sound and alerts.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Colors.blue,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    debugPrint('🔔 Notification clicked: ${notificationResponse.payload}');
    // Handle notification tap here - can navigate to specific screen based on payload
    _handleNotificationPayload(notificationResponse.payload);
  }

  // This needs to be a top-level function
  static void notificationTapBackground(NotificationResponse notificationResponse) {
    // Handle notification tap in background
    debugPrint('🔔 Notification clicked in background: ${notificationResponse.payload}');
  }

  void _handleNotificationPayload(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      try {
        // Parse payload and handle navigation
        debugPrint('📱 Handling notification payload: $payload');
        // Add your navigation logic here based on the payload
        // Example: Navigate to specific screen based on notification type
      } catch (e) {
        debugPrint('❌ Error parsing notification payload: $e');
      }
    }
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      // Request Android permissions with explicit permission check
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        debugPrint('📱 Android notification permission granted: $granted');

        // Also request exact alarm permission for Android 12+
        await androidImplementation.requestExactAlarmsPermission();
      }

      // Request iOS permissions
      final iosImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true, // For critical alerts
        );
        debugPrint('🍎 iOS notification permission granted: $granted');
      }
    } catch (e) {
      debugPrint('❌ Error requesting notification permissions: $e');
    }
  }

  void _setupOneSignalHandlers() {
    // Handle foreground notifications
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint("🔔 OneSignal Notification Received: ${event.notification.title}");
      debugPrint("📱 Body: ${event.notification.body}");
      debugPrint("📊 Additional Data: ${event.notification.additionalData}");

      // Convert OneSignal notification to Local Notification with sound and vibration
      _showLocalNotification(event.notification);

      // Prevent OneSignal from showing its default notification
      event.preventDefault();
    });

    // Handle notification clicked
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('🔔 OneSignal Notification Clicked: ${event.notification.title}');

      // Handle navigation based on additional data
      if (event.notification.additionalData != null) {
        _handleNotificationPayload(event.notification.additionalData.toString());
      }
    });

    // Handle permission changes
    OneSignal.Notifications.addPermissionObserver((state) {
      debugPrint("🔔 OneSignal Permission State: $state");
    });
  }

  Future<void> _showLocalNotification(OSNotification notification) async {
    // Enhanced Android notification settings
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel', // Use the channel we created
      'High Importance Notifications',
      channelDescription: 'Channel for important notifications with sound and alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      color: Colors.blue,
      ledColor: Colors.blue,
      ledOnMs: 1000,
      ledOffMs: 500,
      ticker: notification.title, // Shows in status bar
      autoCancel: true,
      fullScreenIntent: true, // For high priority notifications
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
    );

    // Enhanced iOS notification settings
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default', // Use default system sound
      badgeNumber: 1,
      threadIdentifier: 'app_notifications',
      interruptionLevel: InterruptionLevel.active, // Ensures notification shows
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Create enhanced payload with additional data
    String? payload;
    if (notification.additionalData != null && notification.additionalData!.isNotEmpty) {
      payload = notification.additionalData.toString();
    }

    try {
      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        notification.title ?? 'New Notification',
        notification.body ?? 'You have a new message',
        platformChannelSpecifics,
        payload: payload,
      );
      debugPrint('✅ Local notification shown successfully');
    } catch (e) {
      debugPrint('❌ Error showing local notification: $e');
    }
  }

  // Method to test notifications locally
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Test notification channel',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification with sound!',
      platformChannelSpecifics,
      payload: 'test_payload',
    );
  }

  // Method to handle terminated state notifications
  Future<void> checkForInitialNotification() async {
    try {
      // Check if app was opened from a notification
      final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

      if (notificationAppLaunchDetails != null &&
          notificationAppLaunchDetails.didNotificationLaunchApp &&
          notificationAppLaunchDetails.notificationResponse != null) {

        final payload = notificationAppLaunchDetails.notificationResponse!.payload;
        debugPrint('🚀 App launched from notification with payload: $payload');

        // Handle the notification payload here
        _handleNotificationPayload(payload);
      }
    } catch (e) {
      debugPrint('❌ Error checking initial notification: $e');
    }
  }

  // Get OneSignal Player ID for targeting specific users
  Future<String?> getPlayerId() async {
    try {
      final user = OneSignal.User;
      return user.pushSubscription.id;
    } catch (e) {
      debugPrint('❌ Error getting OneSignal Player ID: $e');
      return null;
    }
  }

  // Method to send tags to OneSignal for user segmentation
  Future<void> sendTags(Map<String, String> tags) async {
    try {
      OneSignal.User.addTags(tags);
      debugPrint('✅ Tags sent to OneSignal: $tags');
    } catch (e) {
      debugPrint('❌ Error sending tags to OneSignal: $e');
    }
  }
}