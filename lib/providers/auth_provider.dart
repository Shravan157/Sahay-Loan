import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';

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
