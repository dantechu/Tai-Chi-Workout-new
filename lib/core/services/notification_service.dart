import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import 'notification_content.dart';

/// Service for managing reminder notifications for inactive users.
///
/// This is a singleton service that:
/// - Schedules reminder notifications at 24hr, 3 days, and 7 days
/// - Cancels all pending notifications when the user returns
/// - Supports localized notification content
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Notification IDs (unique identifiers for each reminder type)
  static const int notificationId24Hr = 1001;
  static const int notificationId3Day = 1002;
  static const int notificationId7Day = 1003;

  // Notification channel configuration
  static const String _channelId = 'reminder_channel';
  static const String _channelName = 'Learning Reminders';
  static const String _channelDescription = 'Reminders to continue learning';

  FlutterLocalNotificationsPlugin? _plugin;
  bool _isInitialized = false;

  /// Initialize the notification service.
  /// Must be called before scheduling any notifications.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz_data.initializeTimeZones();

      _plugin = FlutterLocalNotificationsPlugin();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin!.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions on iOS
      await _plugin!
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      // Request permissions on Android 13+
      await _plugin!
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// Callback when a notification is tapped.
  /// The app will open to the default route.
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.id}');
    // App will open to the default route - no special handling needed
  }

  /// Cancel all pending reminder notifications.
  /// Called when the user opens the app.
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized || _plugin == null) return;

    try {
      await _plugin!.cancel(notificationId24Hr);
      await _plugin!.cancel(notificationId3Day);
      await _plugin!.cancel(notificationId7Day);
      debugPrint('All reminder notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }

  /// Schedule reminder notifications at 24hr, 3 days, and 7 days.
  /// Called when the user leaves the app.
  ///
  /// [languageCode] is used to select the appropriate localized content.
  Future<void> scheduleReminderNotifications(String languageCode) async {
    if (!_isInitialized || _plugin == null) return;

    try {
      // Cancel any existing notifications first
      await cancelAllNotifications();

      final title = NotificationContent.getTitle(languageCode);
      final now = tz.TZDateTime.now(tz.local);

      // Schedule 24-hour notification
      await _scheduleNotification(
        id: notificationId24Hr,
        title: title,
        body: NotificationContent.get24HrBody(languageCode),
        scheduledDate: now.add(const Duration(hours: 24)),
      );

      // Schedule 3-day notification
      await _scheduleNotification(
        id: notificationId3Day,
        title: title,
        body: NotificationContent.get3DayBody(languageCode),
        scheduledDate: now.add(const Duration(days: 3)),
      );

      // Schedule 7-day notification
      await _scheduleNotification(
        id: notificationId7Day,
        title: title,
        body: NotificationContent.get7DayBody(languageCode),
        scheduledDate: now.add(const Duration(days: 7)),
      );

      debugPrint(
          'Reminder notifications scheduled for language: $languageCode');
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
    }
  }

  /// Schedule a single notification at the specified date.
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin!.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: null, // One-time notification
    );
  }

  /// Dispose the notification service.
  void dispose() {
    _plugin = null;
    _isInitialized = false;
  }
}
