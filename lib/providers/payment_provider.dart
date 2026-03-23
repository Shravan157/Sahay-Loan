import 'package:flutter/material.dart';
import '../core/services/payment_service.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_endpoints.dart';
import '../models/payment_model.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  final ApiService _api = ApiService();

  bool _isLoading = false;
  String? _error;
  List<PaymentModel> _paymentHistory = [];
  PaymentModel? _lastPayment;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PaymentModel> get paymentHistory => _paymentHistory;
  PaymentModel? get lastPayment => _lastPayment;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  /// Initialize Stripe
  Future<void> initialize() async {
    await _paymentService.initialize();
  }

  /// Pay EMI using Stripe
  Future<bool> payEMI({
    required String loanId,
    required int month,
    required double amount,
  }) async {
    _setLoading(true);
    _setError(null);

    final result = await _paymentService.payEMI(
      loanId: loanId,
      month: month,
      amount: amount,
    );

    _setLoading(false);

    if (result.isSuccess) {
      _lastPayment = PaymentModel(
        loanId: loanId,
        month: month,
        amount: amount,
        status: 'success',
        paidAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    } else if (result.isCanceled) {
      _setError('Payment canceled');
      return false;
    } else {
      _setError(result.message ?? 'Payment failed');
      return false;
    }
  }

  /// Load payment history from backend (role-based)
  Future<void> loadPaymentHistory() async {
    _setLoading(true);
    _setError(null);

    final response = await _api.get(ApiEndpoints.paymentHistory);

    _setLoading(false);

    if (response.success) {
      final paymentsData = response.data['payments'] as List<dynamic>? ?? [];
      _paymentHistory = paymentsData
          .map((p) => PaymentModel.fromJson(p))
          .toList();
      notifyListeners();
    } else {
      _setError(response.error);
    }
  }

  /// Load payment history for a specific loan (for users)
  Future<void> loadLoanPaymentHistory(String loanId) async {
    _setLoading(true);
    _setError(null);

    // Call paymentHistory which returns all payments, and filter locally
    // (since paymentStatus expects /loan_id/month path params which we don't have here)
    final response = await _api.get(ApiEndpoints.paymentHistory);

    _setLoading(false);

    if (response.success) {
      final paymentsData = response.data['payments'] as List<dynamic>? ?? [];
      _paymentHistory = paymentsData
          .where((p) => p['loan_id'] == loanId)
          .map((p) => PaymentModel.fromJson(p))
          .toList();
      notifyListeners();
    } else {
      _setError(response.error);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
