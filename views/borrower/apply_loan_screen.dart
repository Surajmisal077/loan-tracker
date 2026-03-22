import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/loan_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class ApplyLoanScreen extends StatefulWidget {
  const ApplyLoanScreen({super.key});

  @override
  State<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _talController = TextEditingController();
  final _distController = TextEditingController();
  final _pinController = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();
  final LanguageController _langController = Get.find<LanguageController>();
  late final LoanController _loanController;
  final ImagePicker _picker = ImagePicker();

  String _selectedLoanType = 'agriculture';
  final Map<String, File?> _uploadedDocs = {};
  // PDF track करण्यासाठी
  final Map<String, bool> _isPdfDoc = {};

  @override
  void initState() {
    super.initState();
    _loanController = Get.isRegistered<LoanController>()
        ? Get.find<LoanController>()
        : Get.put(LoanController());
    _initDocs();
  }

  void _initDocs() {
    final docs = _getRequiredDocs(_selectedLoanType);
    _uploadedDocs.clear();
    _isPdfDoc.clear();
    for (final doc in docs) {
      _uploadedDocs[doc['key']!] = null;
      _isPdfDoc[doc['key']!] = false;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _talController.dispose();
    _distController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getRequiredDocs(String loanType) {
    final common = [
      {'key': 'aadhaar', 'label': '🪪 Aadhaar Card', 'required': 'true'},
      {'key': 'pan', 'label': '💳 PAN Card', 'required': 'true'},
      {'key': 'passbook', 'label': '🏦 Bank Passbook', 'required': 'true'},
      {'key': 'photo', 'label': '📸 Passport Size Photo', 'required': 'true'},
      {'key': 'signature', 'label': '✍️ Signature', 'required': 'true'},
    ];

    final specific = <Map<String, String>>[];
    switch (loanType) {
      case 'agriculture':
        specific.addAll([
          {
            'key': 'satbara',
            'label': '📜 7/12 Certificate (सातबारा)',
            'required': 'true',
          },
          {
            'key': 'land_proof',
            'label': '🌾 Land Ownership Proof',
            'required': 'true',
          },
          {
            'key': 'kisan_card',
            'label': '💚 Kisan Credit Card',
            'required': 'false',
          },
          {
            'key': 'crop_details',
            'label': '🌱 Crop Details Document',
            'required': 'false',
          },
        ]);
        break;
      case 'education':
        specific.addAll([
          {
            'key': 'admission',
            'label': '🎓 Admission Letter',
            'required': 'true',
          },
          {
            'key': 'marksheet',
            'label': '📝 Mark Sheet (10th/12th)',
            'required': 'true',
          },
          {
            'key': 'college_id',
            'label': '🪪 College ID Card',
            'required': 'false',
          },
          {
            'key': 'fee_structure',
            'label': '💰 Fee Structure',
            'required': 'true',
          },
        ]);
        break;
      case 'msme':
        specific.addAll([
          {
            'key': 'business_reg',
            'label': '🏭 Business Registration',
            'required': 'true',
          },
          {'key': 'gst', 'label': '📋 GST Certificate', 'required': 'true'},
          {
            'key': 'shop_act',
            'label': '🏪 Shop Act License',
            'required': 'false',
          },
          {'key': 'itr', 'label': '📊 ITR (2 Years)', 'required': 'true'},
          {
            'key': 'bank_statement',
            'label': '🏦 Bank Statement (6 Months)',
            'required': 'true',
          },
        ]);
        break;
      case 'personal':
        specific.addAll([
          {
            'key': 'salary_slip',
            'label': '💵 Salary Slip (3 Months)',
            'required': 'true',
          },
          {
            'key': 'employment',
            'label': '💼 Employment Letter',
            'required': 'true',
          },
          {
            'key': 'bank_statement',
            'label': '🏦 Bank Statement (6 Months)',
            'required': 'true',
          },
          {'key': 'itr', 'label': '📊 ITR (Last Year)', 'required': 'false'},
        ]);
        break;
      case 'home':
        specific.addAll([
          {
            'key': 'property_doc',
            'label': '🏠 Property Document',
            'required': 'true',
          },
          {'key': 'noc', 'label': '📄 NOC from Society', 'required': 'true'},
          {
            'key': 'building_plan',
            'label': '📐 Building Plan Approval',
            'required': 'true',
          },
          {
            'key': 'sale_agreement',
            'label': '📝 Sale Agreement',
            'required': 'false',
          },
          {
            'key': 'property_tax',
            'label': '💰 Property Tax Receipt',
            'required': 'false',
          },
        ]);
        break;
    }
    return [...common, ...specific];
  }

  // ─── Pick Document — Camera / Gallery / PDF ✅ ──────────
  Future<void> _pickDocument(String key) async {
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
            Text('Upload Document 📄', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'Image किंवा PDF upload करा',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // 3 Options: Camera, Gallery, PDF
            Row(
              children: [
                // Camera
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Get.back();
                      final XFile? file = await _picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 85,
                      );
                      if (file != null) {
                        setState(() {
                          _uploadedDocs[key] = File(file.path);
                          _isPdfDoc[key] = false;
                        });
                        Get.snackbar(
                          '✅ Success',
                          'Document captured!',
                          backgroundColor: AppColors.success,
                          colorText: AppColors.textWhite,
                        );
                      }
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
                    onTap: () async {
                      Get.back();
                      final XFile? file = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      if (file != null) {
                        setState(() {
                          _uploadedDocs[key] = File(file.path);
                          _isPdfDoc[key] = false;
                        });
                        Get.snackbar(
                          '✅ Success',
                          'Document selected!',
                          backgroundColor: AppColors.success,
                          colorText: AppColors.textWhite,
                        );
                      }
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
                        setState(() {
                          _uploadedDocs[key] = File(result.files.single.path!);
                          _isPdfDoc[key] = true;
                        });
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

  bool _validateDocs() {
    final docs = _getRequiredDocs(_selectedLoanType);
    for (final doc in docs) {
      if (doc['required'] == 'true' && _uploadedDocs[doc['key']] == null) {
        Get.snackbar(
          '⚠️ Document Missing',
          '${doc['label']} is required!',
          backgroundColor: AppColors.error,
          colorText: AppColors.textWhite,
        );
        return false;
      }
    }
    return true;
  }

  void _applyLoan() async {
    if (_formKey.currentState!.validate()) {
      if (!_validateDocs()) return;

      final uid = _authController.currentUser.value?.uid ?? '';
      final userName = _authController.currentUser.value?.fullName ?? '';

      if (uid.isEmpty) {
        Get.snackbar(
          '❌ Error',
          'User not found! Please login again.',
          backgroundColor: AppColors.error,
          colorText: AppColors.textWhite,
        );
        return;
      }

      final success = await _loanController.applyLoan(
        userId: uid,
        userName: userName,
        loanType: _selectedLoanType,
        totalAmount: double.parse(_amountController.text.trim()),
        purpose: _purposeController.text.trim(),
        mobile: _mobileController.text.trim(),
        address: _addressController.text.trim(),
        tal: _talController.text.trim(),
        dist: _distController.text.trim(),
        pinCode: _pinController.text.trim(),
        documents: _uploadedDocs,
      );

      if (success) {
        Get.offAllNamed(AppRoutes.borrowerDashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = _langController.currentLang.value;

      final List<Map<String, String>> loanTypes = [
        {
          'value': 'agriculture',
          'label': '🌾 ${AppStrings.agricultureLoan}',
          'desc': AppStrings.agricultureDesc,
        },
        {
          'value': 'education',
          'label': '🎓 ${AppStrings.educationLoan}',
          'desc': AppStrings.educationDesc,
        },
        {
          'value': 'msme',
          'label': '🏭 ${AppStrings.msmeLoan}',
          'desc': AppStrings.msmeDesc,
        },
        {
          'value': 'personal',
          'label': '👤 ${AppStrings.personalLoan}',
          'desc': AppStrings.personalDesc,
        },
        {
          'value': 'home',
          'label': '🏠 ${AppStrings.homeLoan}',
          'desc': AppStrings.homeDesc,
        },
      ];

      final requiredDocs = _getRequiredDocs(_selectedLoanType);
      final uploadedCount = _uploadedDocs.values.where((f) => f != null).length;
      final totalCount = requiredDocs.length;

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
                        child: const Text('📋', style: TextStyle(fontSize: 55)),
                      ),
                      const SizedBox(height: 10),
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          AppStrings.applyForNewLoan,
                          style: AppTextStyles.headingWhite,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: Text(
                          AppStrings.officerWillReview,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // STEP 1: Loan Type
                        _buildStepHeader('1', 'Loan Type निवडा 🏷️'),
                        const SizedBox(height: 12),

                        FadeInLeft(
                          duration: const Duration(milliseconds: 600),
                          child: Column(
                            children: loanTypes.map((type) {
                              final isSelected =
                                  _selectedLoanType == type['value'];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedLoanType = type['value']!;
                                    _initDocs();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? AppColors.primary.withValues(
                                                alpha: 0.3,
                                              )
                                            : AppColors.shadow,
                                        blurRadius: isSelected ? 10 : 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        type['label']!.split(' ').first,
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              type['label']!
                                                  .split(' ')
                                                  .skip(1)
                                                  .join(' '),
                                              style: AppTextStyles.subtitle2
                                                  .copyWith(
                                                    color: isSelected
                                                        ? AppColors.textWhite
                                                        : AppColors.textPrimary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Text(
                                              type['desc']!,
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                    color: isSelected
                                                        ? AppColors.textWhite
                                                              .withValues(
                                                                alpha: 0.8,
                                                              )
                                                        : AppColors
                                                              .textSecondary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppColors.textWhite,
                                          size: 22,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // STEP 2: Personal Details
                        _buildStepHeader('2', 'Personal Details 👤'),
                        const SizedBox(height: 12),

                        CustomTextField(
                          label: 'Mobile Number 📱',
                          controller: _mobileController,
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: Validators.validatePhone,
                        ),
                        const SizedBox(height: 12),

                        CustomTextField(
                          label: 'Address / पत्ता 🏠',
                          controller: _addressController,
                          prefixIcon: Icons.home,
                          maxLines: 2,
                          validator: Validators.validateEmpty,
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Taluka / तालुका',
                                controller: _talController,
                                prefixIcon: Icons.location_city,
                                validator: Validators.validateEmpty,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                label: 'District / जिल्हा',
                                controller: _distController,
                                prefixIcon: Icons.map,
                                validator: Validators.validateEmpty,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        CustomTextField(
                          label: 'PIN Code 📮',
                          controller: _pinController,
                          prefixIcon: Icons.pin,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'PIN Code required';
                            }
                            if (value.length != 6) {
                              return 'Invalid PIN Code';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // STEP 3: Loan Details
                        _buildStepHeader('3', 'Loan Details 💰'),
                        const SizedBox(height: 12),

                        CustomTextField(
                          label: '${AppStrings.loanAmount} ₹',
                          controller: _amountController,
                          prefixIcon: Icons.currency_rupee,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: Validators.validateLoanAmount,
                        ),
                        const SizedBox(height: 12),

                        CustomTextField(
                          label: AppStrings.loanPurpose,
                          controller: _purposeController,
                          prefixIcon: Icons.description,
                          maxLines: 3,
                          validator: Validators.validatePurpose,
                        ),

                        const SizedBox(height: 24),

                        // STEP 4: Documents
                        _buildStepHeader('4', 'Documents Upload 📄'),
                        const SizedBox(height: 8),

                        // Progress Bar
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryExtraLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Text('📎', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$uploadedCount / $totalCount documents uploaded',
                                      style: AppTextStyles.subtitle2.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(
                                      value: totalCount > 0
                                          ? uploadedCount / totalCount
                                          : 0,
                                      backgroundColor: AppColors.border,
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Document List
                        Column(
                          children: requiredDocs.map((doc) {
                            final isUploaded =
                                _uploadedDocs[doc['key']] != null;
                            final isRequired = doc['required'] == 'true';
                            final isPdf = _isPdfDoc[doc['key']] ?? false;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isUploaded
                                    ? AppColors.success.withOpacity(0.08)
                                    : AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isUploaded
                                      ? AppColors.success
                                      : isRequired
                                      ? AppColors.error.withOpacity(0.4)
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Status Icon
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isUploaded
                                          ? AppColors.success.withOpacity(0.15)
                                          : AppColors.primaryExtraLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: isUploaded
                                          ? Icon(
                                              isPdf
                                                  ? Icons.picture_as_pdf
                                                  : Icons.check_circle,
                                              color: isUploaded
                                                  ? (isPdf
                                                        ? AppColors.error
                                                        : AppColors.success)
                                                  : AppColors.primary,
                                              size: 24,
                                            )
                                          : Text(
                                              doc['label']!.split(' ').first,
                                              style: const TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Doc Name
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                doc['label']!
                                                    .split(' ')
                                                    .skip(1)
                                                    .join(' '),
                                                style: AppTextStyles.subtitle2,
                                              ),
                                            ),
                                            if (isRequired)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.error
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'Required',
                                                  style: AppTextStyles.caption
                                                      .copyWith(
                                                        color: AppColors.error,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              )
                                            else
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.info
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'Optional',
                                                  style: AppTextStyles.caption
                                                      .copyWith(
                                                        color: AppColors.info,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (isUploaded)
                                          Text(
                                            isPdf
                                                ? '📄 PDF uploaded successfully'
                                                : '✅ Image uploaded successfully',
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  color: AppColors.success,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Upload Button
                                  GestureDetector(
                                    onTap: () => _pickDocument(doc['key']!),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isUploaded
                                            ? AppColors.success
                                            : AppColors.primary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        isUploaded ? 'Change' : 'Upload',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textWhite,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // Info Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.info.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'ℹ️',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Important Information',
                                    style: AppTextStyles.subtitle2.copyWith(
                                      color: AppColors.info,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• ${AppStrings.officerWillReview}\n'
                                '• Image (Camera/Gallery) किंवा PDF upload करा\n'
                                '• Required documents upload करणे अनिवार्य आहे\n'
                                '• Approved झाल्यावर तुम्ही खर्च add करू शकता\n'
                                '• सगळे documents officer ला दिसतील',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Submit Button
                        Obx(
                          () => CustomButton(
                            text: AppStrings.submitApplication,
                            isLoading: _loanController.isLoading.value,
                            onPressed: _applyLoan,
                            icon: Icons.send,
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

  Widget _buildStepHeader(String step, String title) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.subtitle1),
      ],
    );
  }
}
