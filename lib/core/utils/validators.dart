import '../constants/app_strings.dart';

class Validators {
  Validators._();

  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
      return AppStrings.invalidPhone;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }
    if (value != password) {
      return AppStrings.passwordsDontMatch;
    }
    return null;
  }

  static String? validateAadhaar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final aadhaarRegex = RegExp(r'^[0-9]{12}$');
    if (!aadhaarRegex.hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
      return AppStrings.invalidAadhaar;
    }
    return null;
  }

  static String? validatePan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(value.toUpperCase())) {
      return AppStrings.invalidPan;
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final age = int.tryParse(value);
    if (age == null || age < 18 || age > 100) {
      return 'Age must be between 18 and 100';
    }
    return null;
  }

  static String? validateAmount(String? value, {double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final amount = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (min != null && amount < min) {
      return 'Amount must be at least ₹${min.toStringAsFixed(0)}';
    }
    if (max != null && amount > max) {
      return 'Amount must not exceed ₹${max.toStringAsFixed(0)}';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}
