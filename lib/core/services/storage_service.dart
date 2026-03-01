import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token
  Future<void> setToken(String token) async {
    await _prefs?.setString('auth_token', token);
  }

  String? getToken() {
    return _prefs?.getString('auth_token');
  }

  Future<void> removeToken() async {
    await _prefs?.remove('auth_token');
  }

  // User ID
  Future<void> setUserId(String userId) async {
    await _prefs?.setString('user_id', userId);
  }

  String? getUserId() {
    return _prefs?.getString('user_id');
  }

  Future<void> removeUserId() async {
    await _prefs?.remove('user_id');
  }

  // User Role
  Future<void> setUserRole(String role) async {
    await _prefs?.setString('user_role', role);
  }

  String? getUserRole() {
    return _prefs?.getString('user_role');
  }

  Future<void> removeUserRole() async {
    await _prefs?.remove('user_role');
  }

  // Onboarding completed
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs?.setBool('onboarding_completed', completed);
  }

  bool getOnboardingCompleted() {
    return _prefs?.getBool('onboarding_completed') ?? false;
  }

  // User Name
  Future<void> setUserName(String name) async {
    await _prefs?.setString('user_name', name);
  }

  String? getUserName() {
    return _prefs?.getString('user_name');
  }

  // User Email
  Future<void> setUserEmail(String email) async {
    await _prefs?.setString('user_email', email);
  }

  String? getUserEmail() {
    return _prefs?.getString('user_email');
  }

  // KYC Status
  Future<void> setKycVerified(bool verified) async {
    await _prefs?.setBool('kyc_verified', verified);
  }

  bool getKycVerified() {
    return _prefs?.getBool('kyc_verified') ?? false;
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
