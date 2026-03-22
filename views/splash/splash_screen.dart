import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/language_selector.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GetStorage _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await Future.delayed(const Duration(seconds: 3));
    final lang = _storage.read('language');
    if (lang == null) {
      _showLanguageDialog();
    } else {
      _navigateNext();
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Text('🌐', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              'Select Language\nभाषा निवडा\nभाषा चुनें',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading3,
            ),
          ],
        ),
        content: const LanguageSelector(),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateNext();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Continue / पुढे जा', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateNext() async {
    // Firebase current user check करा
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      // कोणी logged in नाही
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    // User logged in आहे — role check करा
    final authController = Get.find<AuthController>();

    // Data load होण्याची वाट पाहा
    int attempts = 0;
    while (authController.currentRole.value.isEmpty && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 300));
      attempts++;
    }

    final role = authController.currentRole.value;
    if (role == 'officer') {
      Get.offAllNamed(AppRoutes.officerDashboard);
    } else if (role == 'borrower') {
      Get.offAllNamed(AppRoutes.borrowerDashboard);
    } else {
      // Role नाही मिळाला — login वर जा
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.textWhite.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🏦', style: TextStyle(fontSize: 60)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'Loan Utilization',
                  style: AppTextStyles.headingWhite.copyWith(fontSize: 28),
                ),
              ),
              const SizedBox(height: 8),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 500),
                child: Text(
                  'कर्ज उपयोग ट्रॅकर',
                  style: AppTextStyles.bodyWhite,
                ),
              ),
              const SizedBox(height: 60),
              FadeIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 800),
                child: const CircularProgressIndicator(
                  color: AppColors.textWhite,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
