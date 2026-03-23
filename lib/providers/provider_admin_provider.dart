import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_endpoints.dart';
import '../models/loan_model.dart';

/// Provider for Lending Company (Provider Admin) operations
class ProviderAdminProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  String? _error;
  List<SharedLoanProfile> _sharedProfiles = [];
  SharedLoanProfile? _selectedProfile;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<SharedLoanProfile> get sharedProfiles => _sharedProfiles;
  List<SharedLoanProfile> get pendingProfiles =>
      _sharedProfiles.where((p) => p.status == 'phase1_shared').toList();
  List<SharedLoanProfile> get fullDetailsRequested =>
      _sharedProfiles.where((p) => p.status == 'phase2_shared').toList();
  List<SharedLoanProfile> get decidedProfiles => _sharedProfiles
      .where((p) => p.status == 'approved' || p.status == 'rejected')
      .toList();
  SharedLoanProfile? get selectedProfile => _selectedProfile;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  /// Load all shared loan profiles for this provider
  Future<void> loadSharedProfiles() async {
    _setLoading(true);
    _setError(null);

    final response = await _api.get(ApiEndpoints.providerSharedProfiles);

    _setLoading(false);

    if (response.success) {
      final profilesData =
          response.data['shared_profiles'] as List<dynamic>? ?? [];
      _sharedProfiles = profilesData
          .map((p) => SharedLoanProfile.fromJson(p))
          .toList();
      notifyListeners();
    } else {
      _setError(response.error);
    }
  }

  /// Request full details (Phase 2) for a shared profile
  Future<bool> requestFullDetails(String shareId, String reason) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.post(
      ApiEndpoints.providerRequestFullDetails,
      body: {'share_id': shareId, 'reason': reason},
    );

    _setLoading(false);

    if (response.success) {
      await loadSharedProfiles();
      return true;
    } else {
      _setError(response.error);
      return false;
    }
  }

  /// Make loan decision (approve or reject)
  Future<bool> makeLoanDecision({
    required String shareId,
    required String decision, // 'approved' or 'rejected'
    String? reason,
    double? offeredInterestRate,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.post(
      ApiEndpoints.providerLoanDecision,
      body: {
        'share_id': shareId,
        'decision': decision,
        'reason': reason,
        'offered_interest_rate': offeredInterestRate,
      },
    );

    _setLoading(false);

    if (response.success) {
      await loadSharedProfiles();
      return true;
    } else {
      _setError(response.error);
      return false;
    }
  }

  void selectProfile(SharedLoanProfile profile) {
    _selectedProfile = profile;
    notifyListeners();
  }

  void clearSelectedProfile() {
    _selectedProfile = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Model for shared loan profile (Phase 1 or Phase 2)
class SharedLoanProfile {
  final String shareId;
  final String loanId;
  final String userId;
  final String userName;
  final String userEmail;
  final double loanAmount;
  final int loanDuration;
  final String purpose;
  final double userRequestedRate;
  final String status; // phase1_shared, phase2_shared, approved, rejected
  final DateTime sharedAt;
  final DateTime? respondedAt;
  final String? responseReason;
  final double? offeredInterestRate;

  // Phase 2 fields (full details)
  final String? aadhaarNumber;
  final String? panNumber;
  final int? age;
  final String? occupation;
  final double? annualIncome;
  final double? creditScore;
  final Map<String, dynamic>? kycDocuments;
  final bool phase2Requested;
  final bool phase2Approved;

  SharedLoanProfile({
    required this.shareId,
    required this.loanId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.loanAmount,
    required this.loanDuration,
    required this.purpose,
    required this.userRequestedRate,
    required this.status,
    required this.sharedAt,
    this.respondedAt,
    this.responseReason,
    this.offeredInterestRate,
    this.aadhaarNumber,
    this.panNumber,
    this.age,
    this.occupation,
    this.annualIncome,
    this.creditScore,
    this.kycDocuments,
    this.phase2Requested = false,
    this.phase2Approved = false,
  });

  factory SharedLoanProfile.fromJson(Map<String, dynamic> json) {
    // Backend stores the loan applicant data in a nested 'phase1_data' object
    final phase1 = json['phase1_data'] as Map<String, dynamic>? ?? {};
    final phase2 = json['phase2_data'] as Map<String, dynamic>? ?? {};

    return SharedLoanProfile(
      shareId: json['share_id'] ?? '',
      loanId: json['loan_id'] ?? '',
      userId: json['user_uid'] ?? json['user_id'] ?? '',
      userName: phase1['name'] ?? json['user_name'] ?? '',
      userEmail: phase2['email'] ?? json['user_email'] ?? '',
      loanAmount: (phase1['loan_amount'] ?? json['loan_amount'] ?? 0)
          .toDouble(),
      loanDuration: phase1['duration_months'] ?? json['loan_duration'] ?? 0,
      purpose: phase1['purpose'] ?? json['purpose'] ?? '',
      userRequestedRate:
          (phase1['requested_interest_rate'] ??
                  json['user_requested_rate'] ??
                  0)
              .toDouble(),
      status: json['status'] ?? 'pending',
      sharedAt: DateTime.tryParse(json['shared_at'] ?? '') ?? DateTime.now(),
      respondedAt: json['decided_at'] != null
          ? DateTime.tryParse(json['decided_at'])
          : null,
      responseReason: json['decision_reason'] ?? json['response_reason'],
      offeredInterestRate: json['offered_interest_rate']?.toDouble(),
      // Phase 1 data fields
      age: phase1['age'] ?? json['age'],
      occupation: phase1['occupation'] ?? json['occupation'],
      annualIncome: (phase1['annual_income'] ?? json['annual_income'])
          ?.toDouble(),
      creditScore:
          null, // credit_score is a string ('Good', 'Poor'), not numeric
      // Phase 2 data fields (sensitive — only shown after admin approval)
      aadhaarNumber: phase2['aadhaar_number'] ?? json['aadhaar_number'],
      panNumber: phase2['pan_number'] ?? json['pan_number'],
      kycDocuments: null,
      phase2Requested: json['phase2_requested'] ?? false,
      phase2Approved: json['phase2_approved'] ?? false,
    );
  }

  bool get isPhase1 => (status == 'phase1_shared' || status == 'pending') && !phase2Requested;
  bool get isPhase2 => status == 'phase2_shared' || (phase2Approved && (status == 'pending' || status == 'phase1_shared'));
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isPending => (status == 'phase1_shared' || status == 'phase2_shared' || status == 'pending');
  bool get hasFullDetails => isPhase2 || isApproved || isRejected;
}
