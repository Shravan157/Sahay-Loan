// Web platform stub - local notifications not supported on web
// This file is used when dart.library.html is available (web platform)

class LocalNotificationsHelper {
  static Future<void> initialize({
    required void Function(dynamic) onNotificationTapped,
  }) async {
    // No-op on web
    print('Local notifications not supported on web');
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Just log on web
    print('Web notification: $title - $body');
  }
}
