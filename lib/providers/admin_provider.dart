import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_endpoints.dart';
import '../models/user_model.dart';
import '../models/loan_model.dart';
import '../models/company_model.dart';

class AdminProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  String? _error;
  List<UserModel> _users = [];
  List<LoanModel> _allLoans = [];
  List<CompanyModel> _companies = [];
  Map<String, dynamic>? _dashboardStats;
  UserModel? _selectedUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserModel> get users => _users;
  List<LoanModel> get allLoans => _allLoans;
  List<LoanModel> get pendingLoans =>
      _allLoans.where((l) => l.isPending || l.isUnderReview).toList();
  List<CompanyModel> get companies => _companies;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  UserModel? get selectedUser => _selectedUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> loadDashboardStats() async {
    _setLoading(true);
    _setError(null);

    final response = await _api.get(ApiEndpoints.adminDashboardStats);

    _setLoading(false);

    if (response.success) {
      _dashboardStats = response.data;
      notifyListeners();
    } else {
      _setError(response.error);
    }
  }

  Future<void> loadAllUsers() async {
    _setLoading(true);
    _setError(null);

    final response = await _api.get(ApiEndpoints.adminAllUsers);

    _setLoading(false);

    if (response.success) {
      final usersData = response.data['users'] as List<dynamic>? ?? [];
      _users = usersData.map((u) => UserModel.fromJson(u)).toList();
      notifyListeners();
    } else {
      _setError(response.error);
    }
  }

  Future<void> loadAllLoans() async {
    _setLoading(true);
    _setError(null);

    final response = await _api.get(ApiEndpoints.adminAllLoans);

    _setLoading(false);

    if (response.success) {
      final loansData = response.data['loans'] as List<dynamic>? ?? [];
      _allLoans = loansData.map((l) => LoanModel.fromJson(l)).toList();
      notifyListeners();
    } else {
      _setError(response.error);
    }
  }

  Future<bool> addCompany(AddCompanyInput input) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.post(
      ApiEndpoints.adminAddCompany,
      body: input.toJson(),
    );

    _setLoading(false);

    if (response.success) {
      return true;
    } else {
      _setError(response.error);
      return false;
    }
  }

  Future<bool> sharePhase1(String loanId, String companyId) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.post(
      ApiEndpoints.adminSharePhase1,
      body: {
        'loan_id': loanId,
        'company_id': companyId,
      },
    );

    _setLoading(false);

    if (response.success) {
      await loadAllLoans();
      return true;
    } else {
      _setError(response.error);
      return false;
    }
  }

  Future<bool> sharePhase2(String shareId, String companyId) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.post(
      ApiEndpoints.adminSharePhase2,
      body: {
        'share_id': shareId,
        'company_id': companyId,
      },
    );

    _setLoading(false);

    if (response.success) {
      return true;
    } else {
      _setError(response.error);
      return false;
    }
  }

  Future<bool> disburseLoan(String loanId) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.post(
      ApiEndpoints.adminDisburseLoan,
      body: {
        'loan_id': loanId,
      },
    );

    _setLoading(false);

    if (response.success) {
      await loadAllLoans();
      return true;
    } else {
      _setError(response.error);
      return false;
    }
  }

  void selectUser(UserModel user) {
    _selectedUser = user;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }
}
