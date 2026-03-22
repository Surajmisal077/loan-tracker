import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/custom_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  int _resendSeconds = 60;
  bool _canResend = false;

  late String _phone;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _phone = args?['phone'] ?? '';
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 60;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
        return true;
      } else {
        setState(() => _canResend = true);
        return false;
      }
    });
  }

  void _verifyOtp() {
    if (_otpController.text.length == 6) {
      _authController.verifyOtp(_otpController.text);
    } else {
      Get.snackbar(
        'Error',
        'Please enter 6 digit OTP',
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
      );
    }
  }

  void _resendOtp() {
    if (_canResend) {
      _authController.sendOtp(_phone);
      _startResendTimer();
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ─── Top Header ────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.textWhite.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: const Text('📱', style: TextStyle(fontSize: 50)),
                    ),

                    const SizedBox(height: 12),

                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        AppStrings.otpVerification,
                        style: AppTextStyles.headingWhite,
                      ),
                    ),

                    const SizedBox(height: 8),

                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'OTP sent to +91 $_phone',
                        style: AppTextStyles.bodyWhite,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── OTP Form ──────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        AppStrings.enterOtp,
                        style: AppTextStyles.heading3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        'Enter the 6-digit code sent to your phone',
                        style: AppTextStyles.body2,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // OTP Input
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(12),
                          fieldHeight: 55,
                          fieldWidth: 45,
                          activeFillColor: AppColors.primaryExtraLight,
                          inactiveFillColor: AppColors.cardBackground,
                          selectedFillColor: AppColors.primaryExtraLight,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.border,
                          selectedColor: AppColors.primary,
                        ),
                        enableActiveFill: true,
                        onChanged: (value) {},
                        onCompleted: (value) => _verifyOtp(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Verify Button
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: Obx(
                        () => CustomButton(
                          text: AppStrings.verifyOtp,
                          isLoading: _authController.isLoading.value,
                          onPressed: _verifyOtp,
                          icon: Icons.verified,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Resend OTP
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
                      child: _canResend
                          ? GestureDetector(
                              onTap: _resendOtp,
                              child: Text(
                                AppStrings.resendOtp,
                                style: AppTextStyles.subtitle2.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                text: 'Resend OTP in ',
                                style: AppTextStyles.body2,
                                children: [
                                  TextSpan(
                                    text: '${_resendSeconds}s',
                                    style: AppTextStyles.subtitle2.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
