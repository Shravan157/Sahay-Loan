import 'dart:math';

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class Helpers {
  Helpers._();

  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final backgroundColor = isError
        ? AppColors.error
        : isSuccess
            ? AppColors.success
            : AppColors.primary;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, min(2, parts[0].length)).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending_sahay_review':
        return AppColors.statusPending;
      case 'under_review':
        return AppColors.statusUnderReview;
      case 'approved':
        return AppColors.statusApproved;
      case 'disbursed':
        return AppColors.statusDisbursed;
      case 'completed':
        return AppColors.statusCompleted;
      case 'rejected':
        return AppColors.statusRejected;
      default:
        return AppColors.textSecondary;
    }
  }

  static Color getCreditScoreColor(String score) {
    switch (score.toLowerCase()) {
      case 'good':
        return AppColors.creditGood;
      case 'standard':
        return AppColors.creditStandard;
      case 'poor':
        return AppColors.creditPoor;
      default:
        return AppColors.textSecondary;
    }
  }

  static LinearGradient getPrimaryGradient() {
    return const LinearGradient(
      colors: AppColors.primaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getSuccessGradient() {
    return const LinearGradient(
      colors: AppColors.successGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static BoxShadow getCardShadow() {
    return BoxShadow(
      color: AppColors.shadow,
      blurRadius: 8,
      offset: const Offset(0, 2),
    );
  }

  static BoxShadow getElevatedShadow() {
    return BoxShadow(
      color: AppColors.shadow,
      blurRadius: 16,
      offset: const Offset(0, 4),
    );
  }

  static String generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        20,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  static double calculateEmi({
    required double principal,
    required double annualRate,
    required int months,
  }) {
    if (annualRate == 0) {
      return principal / months;
    }
    final monthlyRate = annualRate / (12 * 100);
    final emi = principal *
        monthlyRate *
        (pow(1 + monthlyRate, months) / (pow(1 + monthlyRate, months) - 1));
    return emi;
  }

  static double calculateTotalInterest({
    required double principal,
    required double emi,
    required int months,
  }) {
    return (emi * months) - principal;
  }
}
