import '../../models/user_model.dart';
import '../../models/provider_document_model.dart';
import '../constants/api_endpoints.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  // Register
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'user',
  }) async {
    final response = await _api.post(
      ApiEndpoints.register,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role,
      },
    );

    if (response.success) {
      return AuthResult.success(response.data);
    } else {
      return AuthResult.error(response.error ?? 'Registration failed');
    }
  }

  // Register Provider
  Future<AuthResult> registerProvider({
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
    final response = await _api.post(
      ApiEndpoints.register,
      body: {
        'name': companyName,  // Backend expects 'name' not 'company_name'
        'email': email,
        'password': password,
        'phone': phone,
        'role': 'provider_admin',
        'company_type': companyType,
        'cin': cin,
        'gstin': gstin,
        'pan': pan,
        'registered_address': registeredAddress,
        'website': website,
        // Note: documents are handled separately or stored in a different collection
      },
    );

    if (response.success) {
      return AuthResult.success(response.data);
    } else {
      return AuthResult.error(response.error ?? 'Provider registration failed');
    }
  }

  // Login
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      ApiEndpoints.login,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.success) {
      final data = response.data;

      // Save auth data
      await _storage.setToken(data['id_token']);
      await _storage.setUserId(data['uid']);
      await _storage.setUserRole(data['user']['role']);
      await _storage.setUserName(data['user']['name']);
      await _storage.setUserEmail(data['user']['email']);
      await _storage.setKycVerified(data['user']['kyc_verified'] ?? false);

      return AuthResult.success(data);
    } else {
      return AuthResult.error(response.error ?? 'Login failed');
    }
  }

  // Logout
  Future<AuthResult> logout() async {
    final response = await _api.post(ApiEndpoints.logout);

    // Clear local storage regardless of API response
    await _storage.clearAll();

    if (response.success) {
      return AuthResult.success(response.data);
    } else {
      return AuthResult.error(response.error ?? 'Logout failed');
    }
  }

  // Get Profile
  Future<AuthResult> getProfile() async {
    final response = await _api.get(ApiEndpoints.profile);

    if (response.success) {
      final user = UserModel.fromJson(response.data['user']);
      return AuthResult.success(user);
    } else {
      return AuthResult.error(response.error ?? 'Failed to get profile');
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _storage.getToken() != null;
  }

  // Get current user role
  String? getUserRole() {
    return _storage.getUserRole();
  }

  // Get current user ID
  String? getUserId() {
    return _storage.getUserId();
  }

  // Check if user is admin
  bool isAdmin() {
    return _storage.getUserRole() == 'sahay_admin';
  }

  // Check if user is provider admin
  bool isProviderAdmin() {
    return _storage.getUserRole() == 'provider_admin';
  }

  // Check if user is regular user
  bool isUser() {
    return _storage.getUserRole() == 'user';
  }
}

class AuthResult {
  final bool success;
  final dynamic data;
  final String? error;

  AuthResult({
    required this.success,
    this.data,
    this.error,
  });

  factory AuthResult.success(dynamic data) {
    return AuthResult(success: true, data: data);
  }

  factory AuthResult.error(String error) {
    return AuthResult(success: false, error: error);
  }
}
