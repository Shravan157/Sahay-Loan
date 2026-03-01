import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppStrings.rupee,
    decimalDigits: 0,
  );

  static final NumberFormat _currencyFormatWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppStrings.rupee,
    decimalDigits: 2,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,##,###');
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy');

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatCurrencyWithDecimals(double amount) {
    return _currencyFormatWithDecimals.format(amount);
  }

  static String formatNumber(int number) {
    return _numberFormat.format(number);
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static String formatPhoneNumber(String phone) {
    if (phone.length != 10) return phone;
    return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
  }

  static String maskAadhaar(String aadhaar) {
    final clean = aadhaar.replaceAll(RegExp(r'\D'), '');
    if (clean.length != 12) return aadhaar;
    return 'XXXX XXXX ${clean.substring(8)}';
  }

  static String maskPan(String pan) {
    final clean = pan.toUpperCase();
    if (clean.length != 10) return pan;
    return '${clean.substring(0, 2)}XX${clean.substring(4, 5)}X${clean.substring(6, 8)}X';
  }

  static String maskEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];
    if (username.length <= 2) return email;
    return '${username.substring(0, 2)}***@$domain';
  }

  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return AppStrings.goodMorning;
    } else if (hour < 17) {
      return AppStrings.goodAfternoon;
    } else {
      return AppStrings.goodEvening;
    }
  }

  static String formatLoanStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending_sahay_review':
      case 'pending':
        return AppStrings.statusPendingReview;
      case 'under_review':
        return AppStrings.statusUnderReview;
      case 'approved':
        return AppStrings.statusApproved;
      case 'disbursed':
        return AppStrings.statusDisbursed;
      case 'completed':
        return AppStrings.statusCompleted;
      case 'rejected':
        return AppStrings.statusRejected;
      default:
        return status;
    }
  }

  static String formatCreditScore(String score) {
    switch (score.toLowerCase()) {
      case 'good':
        return AppStrings.good;
      case 'standard':
        return AppStrings.standard;
      case 'poor':
        return AppStrings.poor;
      default:
        return score;
    }
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
}

// Helper function for power calculation
double pow(double x, int n) {
  double result = 1;
  for (int i = 0; i < n; i++) {
    result *= x;
  }
  return result;
}
