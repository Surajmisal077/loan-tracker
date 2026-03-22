import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/expense_controller.dart';
import '../../controllers/loan_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  final LoanController _loanController = Get.find<LoanController>();

  String? _selectedLoanId;
  String? _selectedLoanType;

  // ✅ PDF track करण्यासाठी
  bool _isBillPdf = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitExpense() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLoanId == null) {
        Get.snackbar(
          '⚠️ Error',
          'Please select a loan first',
          backgroundColor: AppColors.error,
          colorText: AppColors.textWhite,
        );
        return;
      }
      if (_expenseController.selectedCategory.value.isEmpty) {
        Get.snackbar(
          '⚠️ Error',
          'Please select a category',
          backgroundColor: AppColors.error,
          colorText: AppColors.textWhite,
        );
        return;
      }

      final uid = _authController.currentUser.value?.uid ?? '';
      final success = await _expenseController.addExpense(
        loanId: _selectedLoanId!,
        userId: uid,
        amount: double.parse(_amountController.text.trim()),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
      );

      if (success) Get.back();
    }
  }

  // ─── Bill Picker — Camera / Gallery / PDF ✅ ─────────────
  void _showBillPickerDialog() {
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
            Text('Upload Bill 🧾', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'Image किंवा PDF upload करा',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                // Camera
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      _isBillPdf = false;
                      _expenseController.pickBillFromCamera();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryExtraLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            color: AppColors.primary,
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Camera 📷',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Gallery
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      _isBillPdf = false;
                      _expenseController.pickBillFromGallery();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryExtraLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.photo_library,
                            color: AppColors.primary,
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gallery 🖼️',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // PDF ✅ NEW
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Get.back();
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );
                      if (result != null && result.files.single.path != null) {
                        setState(() => _isBillPdf = true);
                        _expenseController.selectedBillImage.value = File(
                          result.files.single.path!,
                        );
                        Get.snackbar(
                          '✅ Success',
                          'PDF selected!',
                          backgroundColor: AppColors.success,
                          colorText: AppColors.textWhite,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.error,
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'PDF 📄',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
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
                    const SizedBox(height: 16),
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: const Text('📝', style: TextStyle(fontSize: 50)),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        AppStrings.addExpense,
                        style: AppTextStyles.headingWhite,
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
                      // Select Loan
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        child: Text(
                          'Select Loan 💳',
                          style: AppTextStyles.subtitle1,
                        ),
                      ),
                      const SizedBox(height: 8),

                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 100),
                        child: Obx(() {
                          final approvedLoans = _loanController.userLoans
                              .where((l) => l.status == 'approved')
                              .toList();
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedLoanId,
                                hint: Text(
                                  'Choose loan...',
                                  style: AppTextStyles.body2,
                                ),
                                isExpanded: true,
                                items: approvedLoans
                                    .map(
                                      (loan) => DropdownMenuItem(
                                        value: loan.loanId,
                                        child: Text(
                                          '${_getLoanEmoji(loan.loanType)} ${loan.loanType.toUpperCase()} - ₹${loan.remainingAmount.toStringAsFixed(0)} left',
                                          style: AppTextStyles.body2,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedLoanId = value;
                                    _selectedLoanType = approvedLoans
                                        .firstWhere((l) => l.loanId == value)
                                        .loanType;
                                    _expenseController.setCategory('');
                                  });
                                },
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),

                      // Category
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          'Select Category 🏷️',
                          style: AppTextStyles.subtitle1,
                        ),
                      ),
                      const SizedBox(height: 8),

                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: Obx(() {
                          final categories = _expenseController.getCategories(
                            _selectedLoanType ?? '',
                          );
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: categories.map((cat) {
                              final isSelected =
                                  _expenseController.selectedCategory.value ==
                                  cat['value'];
                              return GestureDetector(
                                onTap: () => _expenseController.setCategory(
                                  cat['value']!,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Text(
                                    cat['label']!,
                                    style: AppTextStyles.caption.copyWith(
                                      color: isSelected
                                          ? AppColors.textWhite
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),

                      // Amount
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: CustomTextField(
                          label: 'Amount / रक्कम ₹',
                          controller: _amountController,
                          prefixIcon: Icons.currency_rupee,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: Validators.validateAmount,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
                        child: CustomTextField(
                          label: 'Description / वर्णन',
                          controller: _descriptionController,
                          prefixIcon: Icons.description,
                          maxLines: 2,
                          validator: Validators.validateEmpty,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Location
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 600),
                        child: CustomTextField(
                          label: 'Location / ठिकाण',
                          controller: _locationController,
                          prefixIcon: Icons.location_on,
                          validator: Validators.validateEmpty,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Bill Upload ✅ Image + PDF
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 700),
                        child: Text(
                          'Bill Upload 🧾 (Optional)',
                          style: AppTextStyles.subtitle1,
                        ),
                      ),
                      const SizedBox(height: 8),

                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 800),
                        child: Obx(() {
                          final file =
                              _expenseController.selectedBillImage.value;
                          return GestureDetector(
                            onTap: _showBillPickerDialog,
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.primaryExtraLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: file == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.upload_file,
                                          color: AppColors.primary,
                                          size: 40,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to upload\nImage or PDF',
                                          style: AppTextStyles.body2.copyWith(
                                            color: AppColors.primary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    )
                                  : _isBillPdf
                                  // PDF Preview
                                  ? Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.error.withOpacity(
                                              0.05,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.picture_as_pdf,
                                                color: AppColors.error,
                                                size: 50,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '📄 PDF Selected',
                                                style: AppTextStyles.subtitle2
                                                    .copyWith(
                                                      color: AppColors.error,
                                                    ),
                                              ),
                                              Text(
                                                file.path.split('/').last,
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Close button
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(
                                                () => _isBillPdf = false,
                                              );
                                              _expenseController
                                                  .clearSelectedImage();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: AppColors.error,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: AppColors.textWhite,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  // Image Preview
                                  : Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.file(
                                            file,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () => _expenseController
                                                .clearSelectedImage(),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: AppColors.error,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: AppColors.textWhite,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 28),

                      // Submit Button
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Obx(
                          () => CustomButton(
                            text: _expenseController.isUploading.value
                                ? 'Uploading... 📤'
                                : AppStrings.addExpense,
                            isLoading: _expenseController.isLoading.value,
                            onPressed: _submitExpense,
                            icon: Icons.save,
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

  String _getLoanEmoji(String type) {
    switch (type) {
      case 'agriculture':
        return '🌾';
      case 'education':
        return '🎓';
      case 'msme':
        return '🏭';
      case 'personal':
        return '👤';
      case 'home':
        return '🏠';
      default:
        return '💰';
    }
  }
}
