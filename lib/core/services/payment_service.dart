import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../constants/api_endpoints.dart';
import 'api_service.dart';

/// Service for handling Stripe payments
/// Uses test mode - all transactions are simulated
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final ApiService _api = ApiService();
  bool _isInitialized = false;

  /// Initialize Stripe with publishable key
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Stripe publishable key (test mode)
    Stripe.publishableKey =
        'pk_test_51T5RnkJYhDpfB6PPQM3qBuM1DVd40xPhyW9NWnjj4wwCzstxYK8XPHU7b7lK88VDFuqRiKaKPzRRNRUfFQyWEPlz00W2oh6J4g';

    // Apply settings
    await Stripe.instance.applySettings();
    _isInitialized = true;
  }

  /// Create a payment intent for EMI payment
  Future<PaymentResult> createPaymentIntent({
    required String loanId,
    required int month,
    required double amount,
  }) async {
    try {
      // Call backend to create payment intent
      final response = await _api.post(
        ApiEndpoints.createPaymentIntent,
        body: {'loan_id': loanId, 'month': month, 'amount': amount},
      );

      if (response.success) {
        final clientSecret = response.data['client_secret'];
        final paymentIntentId = response.data['payment_intent_id'];

        return PaymentResult.success(
          clientSecret: clientSecret,
          paymentIntentId: paymentIntentId,
        );
      } else {
        return PaymentResult.error(
          response.error ?? 'Failed to create payment',
        );
      }
    } catch (e) {
      return PaymentResult.error('Error: $e');
    }
  }

  /// Present payment sheet to user
  Future<PaymentResult> presentPaymentSheet({
    required String clientSecret,
    required String loanId,
    required int month,
    required double amount,
  }) async {
    try {
      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'SAHAY Loan App',
          style: ThemeMode.light,
          billingDetails: const BillingDetails(
            name: 'SAHAY User',
            address: Address(
              country: 'IN',
              city: '',
              line1: '',
              line2: '',
              postalCode: '',
              state: '',
            ),
          ),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'IN',
            currencyCode: 'INR',
            testEnv: true,
          ),
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful
      return PaymentResult.success(message: 'Payment successful');
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return PaymentResult.canceled('Payment canceled');
      }
      debugPrint('Stripe Error: ${e.error.message}');
      return PaymentResult.error(e.error.message ?? 'Payment failed');
    } catch (e) {
      debugPrint('Payment Service Error: $e');
      return PaymentResult.error('Error: $e');
    }
  }

  /// Complete payment and confirm with backend
  Future<PaymentResult> confirmPayment({
    required String loanId,
    required int month,
    required String paymentIntentId,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.confirmPayment,
        body: {
          'loan_id': loanId,
          'month': month,
          'payment_intent_id': paymentIntentId,
        },
      );

      if (response.success) {
        return PaymentResult.success(
          message: 'Payment confirmed',
          data: response.data,
        );
      } else {
        return PaymentResult.error(response.error ?? 'Confirmation failed');
      }
    } catch (e) {
      return PaymentResult.error('Error: $e');
    }
  }

  /// Process complete EMI payment flow
  Future<PaymentResult> payEMI({
    required String loanId,
    required int month,
    required double amount,
  }) async {
    // Step 1: Create payment intent
    final createResult = await createPaymentIntent(
      loanId: loanId,
      month: month,
      amount: amount,
    );

    if (!createResult.isSuccess) {
      return createResult;
    }

    // Step 2: Present payment sheet
    final presentResult = await presentPaymentSheet(
      clientSecret: createResult.clientSecret!,
      loanId: loanId,
      month: month,
      amount: amount,
    );

    if (!presentResult.isSuccess) {
      return presentResult;
    }

    // Step 3: Confirm payment with backend
    final confirmResult = await confirmPayment(
      loanId: loanId,
      month: month,
      paymentIntentId: createResult.paymentIntentId!,
    );

    return confirmResult;
  }
}

class PaymentResult {
  final bool isSuccess;
  final bool isCanceled;
  final String? message;
  final String? clientSecret;
  final String? paymentIntentId;
  final dynamic data;

  PaymentResult({
    required this.isSuccess,
    this.isCanceled = false,
    this.message,
    this.clientSecret,
    this.paymentIntentId,
    this.data,
  });

  factory PaymentResult.success({
    String? message,
    String? clientSecret,
    String? paymentIntentId,
    dynamic data,
  }) {
    return PaymentResult(
      isSuccess: true,
      message: message,
      clientSecret: clientSecret,
      paymentIntentId: paymentIntentId,
      data: data,
    );
  }

  factory PaymentResult.error(String message) {
    return PaymentResult(isSuccess: false, message: message);
  }

  factory PaymentResult.canceled(String message) {
    return PaymentResult(isSuccess: false, isCanceled: true, message: message);
  }
}
