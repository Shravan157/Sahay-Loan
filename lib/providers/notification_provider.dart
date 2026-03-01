import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> fetchNotifications() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _api.get('/my-notifications');
      
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final notificationsData = data['notifications'] as List<dynamic>?;
        
        _notifications = notificationsData
                ?.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      } else {
        // If API fails, show empty state (not an error for new users)
        _notifications = [];
        _unreadCount = 0;
      }
    } catch (e) {
      _setError('Failed to load notifications');
      _notifications = [];
      _unreadCount = 0;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
