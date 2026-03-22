import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/language_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/language_selector.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  final LanguageController _langController = Get.find<LanguageController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      _authController.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = _langController.currentLang.value;

      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ─── Header ────────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
                  child: Column(
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: const LanguageSelector(),
                      ),
                      const SizedBox(height: 24),
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: const Text('🏦', style: TextStyle(fontSize: 60)),
                      ),
                      const SizedBox(height: 12),
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: Text(
                          AppStrings.appName,
                          style: AppTextStyles.headingWhite,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: Text(
                          '${AppStrings.hello}! 👋',
                          style: AppTextStyles.bodyWhite,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Email Field
                        FadeInLeft(
                          duration: const Duration(milliseconds: 600),
                          child: CustomTextField(
                            label: AppStrings.email,
                            controller: _emailController,
                            prefixIcon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.validateEmail,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        FadeInLeft(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 200),
                          child: CustomTextField(
                            label: AppStrings.password,
                            controller: _passwordController,
                            prefixIcon: Icons.lock,
                            isPassword: true,
                            validator: Validators.validatePassword,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Login Button
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: Obx(
                            () => CustomButton(
                              text: AppStrings.login,
                              isLoading: _authController.isLoading.value,
                              onPressed: _login,
                              icon: Icons.login,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: AppColors.border),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text('OR', style: AppTextStyles.caption),
                            ),
                            const Expanded(
                              child: Divider(color: AppColors.border),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Register Link
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 200),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${AppStrings.dontHaveAccount} ',
                                style: AppTextStyles.body2,
                              ),
                              GestureDetector(
                                onTap: () => Get.toNamed(AppRoutes.register),
                                child: Text(
                                  AppStrings.registerHere,
                                  style: AppTextStyles.subtitle2.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
