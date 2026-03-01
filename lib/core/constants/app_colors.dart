import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF42A5F5);

  // Secondary Colors
  static const Color secondary = Color(0xFF00897B);
  static const Color secondaryDark = Color(0xFF00695C);
  static const Color secondaryLight = Color(0xFF4DB6AC);

  // Accent Colors
  static const Color accent = Color(0xFFFFB300);
  static const Color accentDark = Color(0xFFFF8F00);
  static const Color accentLight = Color(0xFFFFD54F);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFA000);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Loan Status Colors
  static const Color statusPending = Color(0xFF9E9E9E);
  static const Color statusUnderReview = Color(0xFFFFA000);
  static const Color statusApproved = Color(0xFF00C853);
  static const Color statusDisbursed = Color(0xFF1565C0);
  static const Color statusCompleted = Color(0xFF2E7D32);
  static const Color statusRejected = Color(0xFFE53935);

  // Credit Score Colors
  static const Color creditGood = Color(0xFF00C853);
  static const Color creditStandard = Color(0xFFFFA000);
  static const Color creditPoor = Color(0xFFE53935);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF1565C0),
    Color(0xFF0D47A1),
  ];

  static const List<Color> successGradient = [
    Color(0xFF00C853),
    Color(0xFF00A344),
  ];

  // Divider & Border
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
  static const Color borderLight = Color(0xFFE0E0E0);

  // Shadow
  static const Color shadow = Color(0x1F000000);
  static const Color shadowLight = Color(0x0D000000);
}
