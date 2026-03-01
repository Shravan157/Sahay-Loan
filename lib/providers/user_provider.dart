import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';
import '../models/user_model.dart';
import '../models/kyc_model.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  bool _isLoading = false;
  String? _error;
  UserModel? _user;
  KYCModel? _kyc;
  bool _kycStatusLoaded = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get user => _user;
  KYCModel? get kyc => _kyc;
  bool get hasKYC => _kyc != null && _kyc!.kycVerified;
  bool get kycStatusLoaded => _kycStatusLoaded;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    _setLoading(true);
    _setError(null);

    final response = await _api.get(ApiEndpoints.profile);

    _setLoading(false);

    if (response.success) {
      _user = UserModel.fromJson(response.data['user']);
      notifyListeners();
    } else {
      _setError(response.error);
    }
  }

  Future<void> loadKYCStatus() async {
    _setLoading(true);

    final response = await _api.get(ApiEndpoints.kycStatus);

    _setLoading(false);
    _kycStatusLoaded = true;

    if (response.success && response.data['kyc_verified'] == true) {
      _kyc = KYCModel.fromJson(response.data['kyc']);
      await _storage.setKycVerified(true);
      notifyListeners();
    } else {
      await _storage.setKycVerified(false);
    }
  }

  Future<bool> submitKYC(KYCModel kycData) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.post(
      ApiEndpoints.submitKyc,
      body: kycData.toJson(),
    );

    _setLoading(false);

    if (response.success) {
      _kyc = kycData.copyWith(kycVerified: true);
      await _storage.setKycVerified(true);
      notifyListeners();
      return true;
    } else {
      _setError(response.error);
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
