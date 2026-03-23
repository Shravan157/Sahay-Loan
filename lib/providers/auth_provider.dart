import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_endpoints.dart';
import '../models/user_model.dart';
import '../models/provider_document_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService();

  bool _isLoading = false;
  String? _error;
  UserModel? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get user => _user;
  bool get isLoggedIn => _authService.isLoggedIn();
  bool get isAdmin => _authService.isAdmin();
  bool get isProviderAdmin => _authService.isProviderAdmin();
  bool get isUser => _authService.isUser();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    final result = await _authService.login(
      email: email,
      password: password,
    );

    _setLoading(false);

    if (result.success) {
      await loadUser();
      return true;
    } else {
      _setError(result.error);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _setLoading(true);
    _setError(null);

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );

    _setLoading(false);

    if (result.success) {
      return true;
    } else {
      _setError(result.error);
      return false;
    }
  }

  Future<bool> registerProvider({
    required String companyName,
    required String email,
    required String password,
    required String phone,
    required String companyType,
    required String cin,
    required String gstin,
    required String pan,
    required String registeredAddress,
    String? website,
    required Map<String, BusinessDocument?> documents,
  }) async {
    _setLoading(true);
    _setError(null);

    final result = await _authService.registerProvider(
      companyName: companyName,
      email: email,
      password: password,
      phone: phone,
      companyType: companyType,
      cin: cin,
      gstin: gstin,
      pan: pan,
      registeredAddress: registeredAddress,
      website: website,
      documents: documents,
    );

    _setLoading(false);

    if (result.success) {
      return true;
    } else {
      _setError(result.error);
      return false;
    }
  }

  Future<bool> logout() async {
    _setLoading(true);

    await _authService.logout();
    _user = null;

    _setLoading(false);
    notifyListeners();
    return true;
  }

  Future<void> loadUser() async {
    final result = await _authService.getProfile();
    if (result.success && result.data is UserModel) {
      _user = result.data;
      notifyListeners();
      
      // Update FCM token after user is loaded
      await _updateFcmToken();
    }
  }
  
  /// Update FCM token for push notifications
  Future<void> _updateFcmToken() async {
    try {
      final notificationService = NotificationService();
      final fcmToken = notificationService.fcmToken;
      
      if (fcmToken != null && _user != null) {
        final api = ApiService();
        await api.post(
          ApiEndpoints.updateFcmToken,
          body: {'token': fcmToken},
        );
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String? getUserRole() {
    return _authService.getUserRole();
  }
}
