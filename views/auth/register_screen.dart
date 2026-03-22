import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/language_selector.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _designationController = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();

  // साधा String — Obx नको
  String _selectedRole = 'borrower';

  @override
  void initState() {
    super.initState();
    _selectedRole = _authController.selectedRole.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _bankNameController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      _authController.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        bankName: _bankNameController.text.trim(),
        designation: _designationController.text.trim(),
      );
    }
  }

  void _setRole(String role) {
    setState(() => _selectedRole = role);
    _authController.setRole(role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ─── Top Green Header ──────────────────────
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
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: const LanguageSelector(),
                    ),

                    const SizedBox(height: 20),

                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: const Text('📝', style: TextStyle(fontSize: 50)),
                    ),

                    const SizedBox(height: 12),

                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        AppStrings.register,
                        style: AppTextStyles.headingWhite,
                      ),
                    ),

                    const SizedBox(height: 6),

                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        'Create your account',
                        style: AppTextStyles.bodyWhite,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Form ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Role Selection Label
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        child: Text(
                          AppStrings.selectRole,
                          style: AppTextStyles.subtitle1,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Role Toggle
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 100),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              _buildRoleButton('👨‍🌾 Borrower', 'borrower'),
                              _buildRoleButton('🏦 Bank Officer', 'officer'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Full Name
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: CustomTextField(
                          label: AppStrings.fullName,
                          controller: _nameController,
                          prefixIcon: Icons.person,
                          validator: Validators.validateFullName,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: CustomTextField(
                          label: AppStrings.email,
                          controller: _emailController,
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Phone
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: CustomTextField(
                          label: AppStrings.phoneNumber,
                          controller: _phoneController,
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: Validators.validatePhone,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Password
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
                        child: CustomTextField(
                          label: AppStrings.password,
                          controller: _passwordController,
                          prefixIcon: Icons.lock,
                          isPassword: true,
                          validator: Validators.validatePassword,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 600),
                        child: CustomTextField(
                          label: AppStrings.confirmPassword,
                          controller: _confirmPasswordController,
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (value) =>
                              Validators.validateConfirmPassword(
                                value,
                                _passwordController.text,
                              ),
                        ),
                      ),

                      // Officer Extra Fields
                      if (_selectedRole == 'officer') ...[
                        const SizedBox(height: 16),
                        FadeInLeft(
                          duration: const Duration(milliseconds: 600),
                          child: CustomTextField(
                            label: 'Bank Name / बँकेचे नाव',
                            controller: _bankNameController,
                            prefixIcon: Icons.account_balance,
                            validator: Validators.validateEmpty,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInLeft(
                          duration: const Duration(milliseconds: 600),
                          child: CustomTextField(
                            label: 'Designation / पद',
                            controller: _designationController,
                            prefixIcon: Icons.badge,
                            validator: Validators.validateEmpty,
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Register Button — फक्त isLoading साठी Obx ✅
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Obx(
                          () => CustomButton(
                            text: AppStrings.register,
                            isLoading: _authController.isLoading.value,
                            onPressed: _register,
                            icon: Icons.app_registration,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Login Link
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTextStyles.body2,
                            ),
                            GestureDetector(
                              onTap: () => Get.offAllNamed(AppRoutes.login),
                              child: Text(
                                'Login',
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
  }

  Widget _buildRoleButton(String label, String role) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setRole(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.subtitle2.copyWith(
                color: isSelected
                    ? AppColors.textWhite
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
