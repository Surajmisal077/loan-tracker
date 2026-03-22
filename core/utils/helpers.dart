import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class Helpers {
  // Format Currency ₹
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Format Date
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Format DateTime
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  // Show Success Toast
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  // Show Error Toast
  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  // Show Warning Toast
  static void showWarning(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColors.warning,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  // ✅ Show Info Toast — नवीन add केला
  static void showInfo(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColors.info,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  // Show Loading Dialog
  static void showLoading() {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      barrierDismissible: false,
    );
  }

  // Hide Loading Dialog
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  // Calculate Loan Utilization Percentage
  static double calculateUtilization(double used, double total) {
    if (total <= 0) return 0;
    return (used / total * 100).clamp(0, 100);
  }

  // Get Utilization Color
  static Color getUtilizationColor(double percentage) {
    if (percentage <= 50) return AppColors.success;
    if (percentage <= 80) return AppColors.warning;
    return AppColors.error;
  }

  // Get Status Color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }
}
