import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_endpoints.dart';
import '../models/user_model.dart';
import '../models/loan_model.dart';
import '../models/company_model.dart';
import 'provider_admin_provider.dart';

class AdminProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  String? _error;
  List<UserModel> _users = [];
  List<LoanModel> _allLoans = [];
  List<CompanyModel> _companies = [];
  List<SharedLoanProfile> _sharedProfiles = [];
  Map<String, dynamic>? _dashboardStats;
  UserModel? _selectedUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserModel> get users => _users;
  List<LoanModel> get allLoans => _allLoans;
  List<LoanModel> get pendingLoans =>
      _allLoans.where((l) => l.isPending || l.isUnderReview).toList();
  List<CompanyModel> get companies => _companies;
  List<SharedLoanProfile> get sharedProfiles => _sharedProfiles;
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

    // The backend doesn't have a dashboard-stats endpoint
    // Instead we load users and loans and compute the counts locally
    await loadAllUsers();
    await loadAllLoans();

    _dashboardStats = {
      'total_users': _users.length,
      'active_loans': _allLoans
          .where((l) => l.isApproved || l.isDisbursed)
          .length,
      'pending_loans': pendingLoans.length,
    };

    _setLoading(false);
    notifyListeners();
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

  Future<void> loadAllCompanies() async {
    _setLoading(true);
    _setError(null);

    final response = await _api.get(ApiEndpoints.adminAllCompanies);

    _setLoading(false);

    if (response.success) {
      final companiesData = response.data['companies'] as List<dynamic>? ?? [];
      _companies = companiesData.map((c) => CompanyModel.fromJson(c)).toList();
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
      body: {'loan_id': loanId, 'company_id': companyId},
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
      body: {'share_id': shareId, 'company_id': companyId},
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
      '${ApiEndpoints.adminDisburseLoan}/$loanId',
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

  Future<void> loadSharedProfiles() async {
    _setLoading(true);
    _setError(null);

    final response = await _api.get(ApiEndpoints.adminSharedProfiles);

    _setLoading(false);

    if (response.success) {
      final profilesData = response.data['profiles'] as List<dynamic>? ?? [];
      _sharedProfiles = profilesData.map((p) => SharedLoanProfile.fromJson(p)).toList();
      notifyListeners();
    } else {
      _setError(response.error);
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
