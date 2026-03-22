import '../constants/app_strings.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return AppStrings.emailRequired;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return AppStrings.invalidEmail;
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return AppStrings.passwordRequired;
    if (value.length < 6) return AppStrings.passwordTooShort;
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty)
      return AppStrings.confirmPasswordRequired;
    if (value != password) return AppStrings.passwordsDoNotMatch;
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) return AppStrings.nameRequired;
    if (value.length < 2) return AppStrings.nameRequired;
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return AppStrings.phoneRequired;
    if (value.length != 10) return AppStrings.phoneInvalid;
    return null;
  }

  static String? validateEmpty(String? value) {
    if (value == null || value.isEmpty) return AppStrings.fieldRequired;
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) return AppStrings.amountRequired;
    final amount = double.tryParse(value);
    if (amount == null) return AppStrings.amountRequired;
    if (amount <= 0) return AppStrings.amountRequired;
    return null;
  }

  static String? validateLoanAmount(String? value) {
    if (value == null || value.isEmpty) return AppStrings.amountRequired;
    final amount = double.tryParse(value);
    if (amount == null) return AppStrings.amountRequired;
    if (amount < 1000) return AppStrings.amountMin;
    if (amount > 10000000) return AppStrings.amountMax;
    return null;
  }

  static String? validatePurpose(String? value) {
    if (value == null || value.isEmpty) return AppStrings.fieldRequired;
    if (value.length < 10) return AppStrings.purposeTooShort;
    return null;
  }
}
