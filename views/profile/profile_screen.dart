import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _designationController = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();
  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    if (_authController.currentRole.value == 'officer') {
      final officer = _authController.currentOfficer.value;
      _nameController.text = officer?.fullName ?? '';
      _phoneController.text = officer?.phone ?? '';
      _bankNameController.text = officer?.bankName ?? '';
      _designationController.text = officer?.designation ?? '';
    } else {
      final user = _authController.currentUser.value;
      _nameController.text = user?.fullName ?? '';
      _phoneController.text = user?.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bankNameController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final uid = _authController.currentRole.value == 'officer'
          ? _authController.currentOfficer.value?.uid ?? ''
          : _authController.currentUser.value?.uid ?? '';

      if (_authController.currentRole.value == 'officer') {
        await _profileController.updateOfficerProfile(
          uid: uid,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          bankName: _bankNameController.text.trim(),
          designation: _designationController.text.trim(),
        );
      } else {
        await _profileController.updateBorrowerProfile(
          uid: uid,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
      }
    }
  }

  void _showImagePickerDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.changePhoto, style: AppTextStyles.heading3),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      _profileController.pickProfileImageFromCamera();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryExtraLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            color: AppColors.primary,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text('Camera 📷', style: AppTextStyles.subtitle2),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      _profileController.pickProfileImageFromGallery();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryExtraLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.photo_library,
                            color: AppColors.primary,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text('Gallery 🖼️', style: AppTextStyles.subtitle2),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ─── Header ──────────────────────────────
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
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.textWhite.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          AppStrings.profile,
                          style: AppTextStyles.headingWhite,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Profile Image
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Obx(() {
                        final selectedImage =
                            _profileController.selectedProfileImage.value;
                        final networkImage = _authController.profileImage;

                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryExtraLight,
                                border: Border.all(
                                  color: AppColors.textWhite,
                                  width: 3,
                                ),
                                image: selectedImage != null
                                    ? DecorationImage(
                                        image: FileImage(selectedImage),
                                        fit: BoxFit.cover,
                                      )
                                    : networkImage.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(networkImage),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child:
                                  selectedImage == null && networkImage.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showImagePickerDialog,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: AppColors.textWhite,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 12),

                    // Name & Email
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: Obx(
                        () => Text(
                          _authController.displayName,
                          style: AppTextStyles.headingWhite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: Obx(
                        () => Text(
                          _authController.displayEmail,
                          style: AppTextStyles.bodyWhite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Role Badge
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
                      child: Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textWhite.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _authController.currentRole.value == 'officer'
                                ? '🏦 Bank Officer'
                                : '👨‍🌾 Borrower',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Form ────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        child: Text(
                          AppStrings.editProfile,
                          style: AppTextStyles.heading3,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Full Name — ✅ Obx नाही
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 100),
                        child: CustomTextField(
                          label: AppStrings.fullName,
                          controller: _nameController,
                          prefixIcon: Icons.person,
                          validator: Validators.validateFullName,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Phone — ✅ Obx नाही
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
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

                      // Officer Extra Fields
                      Obx(() {
                        if (_authController.currentRole.value == 'officer') {
                          return Column(
                            children: [
                              const SizedBox(height: 16),
                              FadeInLeft(
                                duration: const Duration(milliseconds: 600),
                                delay: const Duration(milliseconds: 300),
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
                                delay: const Duration(milliseconds: 400),
                                child: CustomTextField(
                                  label: 'Designation / पद',
                                  controller: _designationController,
                                  prefixIcon: Icons.badge,
                                  validator: Validators.validateEmpty,
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox();
                      }),

                      const SizedBox(height: 28),

                      // Save Button
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Obx(
                          () => CustomButton(
                            text: AppStrings.save,
                            isLoading: _profileController.isLoading.value,
                            onPressed: _saveProfile,
                            icon: Icons.save,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ✅ Logout Button — Obx नाही
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.defaultDialog(
                              title: 'Logout',
                              middleText: 'Are you sure you want to logout?',
                              textConfirm: AppStrings.logout,
                              textCancel: AppStrings.cancel,
                              confirmTextColor: AppColors.textWhite,
                              buttonColor: AppColors.error,
                              onConfirm: () {
                                Get.back();
                                _authController.logout();
                              },
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 55),
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.logout,
                            color: AppColors.error,
                          ),
                          label: Text(
                            AppStrings.logout,
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.error,
                            ),
                          ),
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
}
