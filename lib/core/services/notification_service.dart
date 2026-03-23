import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';

// Conditional import for local notifications
// Only import on non-web platforms
import 'notification_service_stub.dart'
    if (dart.library.html) 'notification_service_web.dart'
    as local_notifications;

/// Service for handling Firebase Cloud Messaging (FCM) push notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _fcmToken;
  bool _isInitialized = false;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  /// Initialize FCM and local notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Skip FCM on web platform
      if (kIsWeb) {
        print('Running on web - FCM notifications limited');
        _isInitialized = true;
        return;
      }

      // Request permission for notifications
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        print('FCM Token: $_fcmToken');

        // Initialize local notifications for foreground messages
        await _initLocalNotifications();

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background message taps
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

        // Handle initial message (when app is opened from notification)
        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleMessageTap(initialMessage);
        }

        // Listen to token refresh
        _messaging.onTokenRefresh.listen((token) {
          _fcmToken = token;
          // TODO: Send new token to backend
        });

        _isInitialized = true;
      }
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  /// Initialize local notifications for showing notifications in foreground
  Future<void> _initLocalNotifications() async {
    await local_notifications.LocalNotificationsHelper.initialize(
      onNotificationTapped: _onNotificationTapped,
    );
  }

  /// Handle foreground messages (when app is open)
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      _showLocalNotification(
        id: notification.hashCode,
        title: notification.title ?? 'SAHAY',
        body: notification.body ?? '',
        data: data,
      );
    }
  }

  /// Handle notification tap
  void _handleMessageTap(RemoteMessage message) {
    final data = message.data;
    _navigateBasedOnData(data);
  }

  /// Handle local notification tap
  void _onNotificationTapped(dynamic response) {
    final payload = response?.payload;
    if (payload != null) {
      // Parse payload and navigate
      // For now, just log it
      print('Notification tapped: $payload');
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await local_notifications.LocalNotificationsHelper.show(
      id: id,
      title: title,
      body: body,
      payload: data?.toString(),
    );
  }

  /// Navigate based on notification data
  void _navigateBasedOnData(Map<String, dynamic> data) {
    final type = data['type'];
    // Navigation will be handled by the app
    // For now, just log
    print('Navigate to: $type');
  }

  /// Show a local notification (can be called from anywhere)
  Future<void> showNotification({
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      data: {...?data, 'type': type},
    );
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}

/// Notification types for the app
class NotificationType {
  static const String welcome = 'welcome';
  static const String kycSubmitted = 'kyc_submitted';
  static const String kycVerified = 'kyc_verified';
  static const String kycRejected = 'kyc_rejected';
  static const String loanApplied = 'loan_applied';
  static const String loanApproved = 'loan_approved';
  static const String loanRejected = 'loan_rejected';
  static const String loanDisbursed = 'loan_disbursed';
  static const String emiDue = 'emi_due';
  static const String emiPaid = 'emi_paid';
  static const String paymentSuccess = 'payment_success';
  static const String paymentFailed = 'payment_failed';
}
