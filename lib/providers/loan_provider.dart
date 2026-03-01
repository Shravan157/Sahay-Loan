import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_endpoints.dart';
import '../models/loan_model.dart';
import '../models/credit_score_model.dart';

class LoanProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  String? _error;
  List<LoanModel> _loans = [];
  LoanModel? _selectedLoan;
  List<RepaymentModel> _repayments = [];
  CreditScoreModel? _creditScore;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<LoanModel> get loans => _loans;
  LoanModel? get selectedLoan => _selectedLoan;
  List<RepaymentModel> get repayments => _repayments;
  CreditScoreModel? get creditScore => _creditScore;

  List<LoanModel> get activeLoans =>
      _loans.where((l) => l.isPending || l.isUnderReview || l.isApproved || l.isDisbursed).toList();
  List<LoanModel> get pendingLoans =>
      _loans.where((l) => l.isPending || l.isUnderReview).toList();
  List<LoanModel> get completedLoans =>
      _loans.where((l) => l.isCompleted).toList();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> loadMyLoans() async {
    _setLoading(true);
    _setError(null);

    final response = await _api.get(ApiEndpoints.myLoans);

    _setLoading(false);

    if (response.success) {
      final loansData = response.data['loans'] as List<dynamic>? ?? [];
      _loans = loansData.map((l) => LoanModel.fromJson(l)).toList();
      notifyListeners();
    } else {
      _setError(response.error);
    }
  }

  Future<bool> applyForLoan(LoanApplicationInput input) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.post(
      ApiEndpoints.applyLoan,
      body: input.toJson(),
    );

    _setLoading(false);

    if (response.success) {
      await loadMyLoans();
      return true;
    } else {
      _setError(response.error);
      return false;
    }
  }

  Future<void> loadLoanDetails(String loanId) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.get(ApiEndpoints.loanStatus(loanId));

    _setLoading(false);

    if (response.success) {
      _selectedLoan = LoanModel.fromJson(response.data['loan']);
      notifyListeners();
    } else {
      _setError(response.error);
    }
  }

  Future<void> loadRepaymentSchedule(String loanId) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.get(ApiEndpoints.repaymentSchedule(loanId));

    _setLoading(false);

    if (response.success) {
      final scheduleData = response.data['schedule'] as List<dynamic>? ?? [];
      _repayments = scheduleData.map((r) => RepaymentModel.fromJson(r)).toList();
      notifyListeners();
    } else {
      _setError(response.error);
    }
  }

  Future<bool> payEMI(String loanId, int month, double amount) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.post(
      ApiEndpoints.payEmi,
      body: {
        'loan_id': loanId,
        'month': month,
        'amount': amount,
      },
    );

    _setLoading(false);

    if (response.success) {
      await loadRepaymentSchedule(loanId);
      return true;
    } else {
      _setError(response.error);
      return false;
    }
  }

  Future<bool> predictCreditScore(CreditScoreInput input) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.post(
      ApiEndpoints.predictCreditScore,
      body: input.toJson(),
    );

    _setLoading(false);

    if (response.success) {
      _creditScore = CreditScoreModel(
        uid: '',
        creditScore: response.data['credit_score'] ?? '',
        eligible: response.data['eligible'] ?? false,
      );
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

  void clearSelectedLoan() {
    _selectedLoan = null;
    _repayments = [];
    notifyListeners();
  }
}
