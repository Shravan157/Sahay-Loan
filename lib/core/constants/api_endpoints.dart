import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Automatically switches based on platform
  // For web/chrome: http://localhost:8000
  // For mobile/emulator: http://192.168.3.1:8000 (your computer's IP)
  static String get baseUrl {
    if (kIsWeb) {
      // Running on Chrome/web browser
      return 'http://localhost:8000';
    } else {
      // Running on mobile device or emulator
      return 'http://192.168.3.1:8000';
    }
  }
  
  static const String apiVersion = '';

  // Auth Endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String profile = '/profile';

  // KYC Endpoints
  static const String submitKyc = '/submit-kyc';
  static const String kycStatus = '/kyc-status';
  static const String getKycStatus = '/kyc-status';
  static const String updateKyc = '/update-kyc';
  static const String ocrScan = '/ocr-scan';

  // Credit Score Endpoints
  static const String predictCreditScore = '/predict-credit-score';

  // Loan Endpoints
  static const String applyLoan = '/apply-loan';
  static const String myLoans = '/my-loans';
  static String loanStatus(String loanId) => '/loan-status/$loanId';
  static String repaymentSchedule(String loanId) =>
      '/repayment-schedule/$loanId';
  static const String payEmi = '/pay-emi';

  // Notification Endpoints
  static const String myNotifications = '/my-notifications';

  // Admin Endpoints
  static const String adminPrefix = '/sahay-admin';
  static const String adminDashboardStats = '$adminPrefix/dashboard-stats';
  static const String adminAllUsers = '$adminPrefix/all-users';
  static const String adminAllLoans = '$adminPrefix/all-loans';
  static const String adminAddCompany = '$adminPrefix/add-company';
  static const String adminSharePhase1 = '$adminPrefix/share-phase1';
  static const String adminSharePhase2 = '$adminPrefix/share-phase2';
  static const String adminDisburseLoan = '$adminPrefix/disburse-loan';

  // Provider Endpoints
  static const String providerPrefix = '/provider-admin';
  static const String providerSharedProfiles =
      '$providerPrefix/shared-profiles';
  static const String providerRequestFullDetails =
      '$providerPrefix/request-full-details';
  static const String providerLoanDecision = '$providerPrefix/loan-decision';

  // Helper method to get full URL
  static String getUrl(String endpoint) {
    return '${baseUrl}$endpoint';
  }
}
