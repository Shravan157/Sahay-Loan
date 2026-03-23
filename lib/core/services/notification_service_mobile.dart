// Mobile platform implementation for local notifications
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsHelper {
  static final FlutterLocalNotificationsPlugin notifications = 
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize({
    required void Function(NotificationResponse) onNotificationTapped,
  }) async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: onNotificationTapped,
    );
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'sahay_channel',
      'SAHAY Notifications',
      channelDescription: 'Notifications from SAHAY Loan App',
      importance: Importance.high,
      priority: Priority.high,
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

    await notifications.show(id, title, body, details, payload: payload);
  }
}
