import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/loan_controller.dart';
import '../../controllers/officer_controller.dart';
import '../../controllers/expense_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../widgets/expense_card.dart';

class LoanApprovalScreen extends StatefulWidget {
  const LoanApprovalScreen({super.key});

  @override
  State<LoanApprovalScreen> createState() => _LoanApprovalScreenState();
}

class _LoanApprovalScreenState extends State<LoanApprovalScreen> {
  final LoanController _loanController = Get.find<LoanController>();
  final AuthController _authController = Get.find<AuthController>();
  late final OfficerController _officerController;
  late final ExpenseController _expenseController;

  final _noteController = TextEditingController();
  final _alertController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _officerController = Get.isRegistered<OfficerController>()
        ? Get.find<OfficerController>()
        : Get.put(OfficerController());

    _expenseController = Get.isRegistered<ExpenseController>()
        ? Get.find<ExpenseController>()
        : Get.put(ExpenseController());

    final loanId = _loanController.selectedLoan.value?.loanId ?? '';
    if (loanId.isNotEmpty) {
      _expenseController.loadLoanExpenses(loanId);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _alertController.dispose();
    super.dispose();
  }

  // ─── Document Label Helper ────────────────────────────────
  String _getDocLabel(String key) {
    const labels = {
      'aadhaar': '🪪 Aadhaar Card',
      'pan': '💳 PAN Card',
      'passbook': '🏦 Bank Passbook',
      'photo': '📸 Passport Photo',
      'signature': '✍️ Signature',
      'satbara': '📜 7/12 Certificate',
      'land_proof': '🌾 Land Ownership',
      'kisan_card': '💚 Kisan Credit Card',
      'crop_details': '🌱 Crop Details',
      'admission': '🎓 Admission Letter',
      'marksheet': '📝 Mark Sheet',
      'college_id': '🪪 College ID',
      'fee_structure': '💰 Fee Structure',
      'business_reg': '🏭 Business Registration',
      'gst': '📋 GST Certificate',
      'shop_act': '🏪 Shop Act License',
      'itr': '📊 ITR',
      'bank_statement': '🏦 Bank Statement',
      'salary_slip': '💵 Salary Slip',
      'employment': '💼 Employment Letter',
      'property_doc': '🏠 Property Document',
      'noc': '📄 NOC',
      'building_plan': '📐 Building Plan',
      'sale_agreement': '📝 Sale Agreement',
      'property_tax': '💰 Property Tax',
    };
    return labels[key] ?? '📄 $key';
  }

  // ─── Doc Image Widget ✅ CachedNetworkImage ───────────────
  Widget _buildDocImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) => Container(
        color: AppColors.primaryExtraLight,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.primaryExtraLight,
        child: const Center(
          child: Icon(
            Icons.insert_drive_file,
            size: 30,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  // ─── View Document Full Screen ────────────────────────────
  void _viewDocument(String url, String label) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.subtitle2.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, color: AppColors.textWhite),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              constraints: BoxConstraints(maxHeight: Get.height * 0.6),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text('Failed to load image'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog() {
    Get.defaultDialog(
      title: '✅ Approve Loan',
      content: Column(
        children: [
          Text(
            'Are you sure you want to approve this loan?',
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: AppStrings.addNote,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            maxLines: 2,
          ),
        ],
      ),
      textConfirm: AppStrings.approveLoan,
      textCancel: AppStrings.cancel,
      confirmTextColor: AppColors.textWhite,
      buttonColor: AppColors.success,
      onConfirm: () async {
        Get.back();
        final loan = _loanController.selectedLoan.value;
        if (loan != null) {
          await _officerController.approveLoan(
            loanId: loan.loanId,
            userId: loan.userId,
            note: _noteController.text.trim(),
          );
          Get.back();
        }
      },
    );
  }

  void _showRejectDialog() {
    Get.defaultDialog(
      title: '❌ Reject Loan',
      content: Column(
        children: [
          Text(
            'Are you sure you want to reject this loan?',
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: AppStrings.reasonForRejection,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error),
              ),
            ),
            maxLines: 2,
          ),
        ],
      ),
      textConfirm: AppStrings.rejectLoan,
      textCancel: AppStrings.cancel,
      confirmTextColor: AppColors.textWhite,
      buttonColor: AppColors.error,
      onConfirm: () async {
        Get.back();
        final loan = _loanController.selectedLoan.value;
        if (loan != null) {
          await _officerController.rejectLoan(
            loanId: loan.loanId,
            userId: loan.userId,
            note: _noteController.text.trim(),
          );
          Get.back();
        }
      },
    );
  }

  void _showAlertDialog() {
    Get.defaultDialog(
      title: '🚨 Send Alert',
      content: Column(
        children: [
          Text(
            AppStrings.sendAlertToBorrower,
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _alertController,
            decoration: InputDecoration(
              hintText: AppStrings.alertMessage,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.warning),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
      textConfirm: AppStrings.sendAlert,
      textCancel: AppStrings.cancel,
      confirmTextColor: AppColors.textWhite,
      buttonColor: AppColors.warning,
      onConfirm: () async {
        Get.back();
        final loan = _loanController.selectedLoan.value;
        final officerId = _authController.currentOfficer.value?.uid ?? '';
        if (loan != null && _alertController.text.isNotEmpty) {
          await _officerController.sendAlert(
            userId: loan.userId,
            loanId: loan.loanId,
            message: _alertController.text.trim(),
            officerId: officerId,
          );
          _alertController.clear();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Obx(() {
        final loan = _loanController.selectedLoan.value;
        if (loan == null) {
          return const Center(child: Text('No loan selected'));
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
                onPressed: () => Get.back(),
              ),
              actions: [
                IconButton(
                  onPressed: _showAlertDialog,
                  icon: const Icon(
                    Icons.notifications_active,
                    color: AppColors.textWhite,
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '🏦 ${AppStrings.loanReview}',
                        style: AppTextStyles.headingWhite,
                      ),
                      const SizedBox(height: 4),
                      Text(loan.userName, style: AppTextStyles.bodyWhite),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Helpers.getStatusColor(
                            loan.status,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Helpers.getStatusColor(loan.status),
                          ),
                        ),
                        child: Text(
                          loan.status.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Cards
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildAmountCard(
                              title: AppStrings.totalLoan,
                              amount: loan.totalAmount,
                              color: AppColors.primary,
                              icon: '💰',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildAmountCard(
                              title: AppStrings.usedAmount,
                              amount: loan.usedAmount,
                              color: AppColors.warning,
                              icon: '📊',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildAmountCard(
                              title: AppStrings.remainingAmount,
                              amount: loan.remainingAmount,
                              color: AppColors.success,
                              icon: '✅',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Utilization Bar
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppStrings.utilization,
                                  style: AppTextStyles.subtitle1,
                                ),
                                Text(
                                  '${loan.utilizationPercentage.toStringAsFixed(1)}%',
                                  style: AppTextStyles.subtitle1.copyWith(
                                    color: Helpers.getUtilizationColor(
                                      loan.utilizationPercentage,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearPercentIndicator(
                              lineHeight: 14,
                              percent: (loan.utilizationPercentage / 100).clamp(
                                0.0,
                                1.0,
                              ),
                              backgroundColor: AppColors.primaryExtraLight,
                              progressColor: Helpers.getUtilizationColor(
                                loan.utilizationPercentage,
                              ),
                              barRadius: const Radius.circular(7),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Loan Info
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.loanDetails,
                              style: AppTextStyles.subtitle1,
                            ),
                            const Divider(height: 20),
                            _buildInfoRow('👤 Borrower', loan.userName),
                            _buildInfoRow(
                              '🏷️ Type',
                              loan.loanType.toUpperCase(),
                            ),
                            _buildInfoRow('🎯 Purpose', loan.purpose),
                            _buildInfoRow(
                              '📅 Date',
                              Helpers.formatDate(loan.createdAt),
                            ),
                            if (loan.mobile.isNotEmpty)
                              _buildInfoRow('📱 Mobile', loan.mobile),
                            if (loan.address.isNotEmpty)
                              _buildInfoRow('🏠 Address', loan.address),
                            if (loan.tal.isNotEmpty)
                              _buildInfoRow('🏙️ Taluka', loan.tal),
                            if (loan.dist.isNotEmpty)
                              _buildInfoRow('🗺️ District', loan.dist),
                            if (loan.pinCode.isNotEmpty)
                              _buildInfoRow('📮 PIN Code', loan.pinCode),
                            if (loan.officerNote != null &&
                                loan.officerNote!.isNotEmpty)
                              _buildInfoRow('📝 Note', loan.officerNote!),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─── Documents Section ✅ ────────────
                    if (loan.documentUrls.isNotEmpty) ...[
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 250),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '📄',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Submitted Documents',
                                    style: AppTextStyles.subtitle1,
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryExtraLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${loan.documentUrls.length} docs',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),

                              // Document Grid
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 1.5,
                                    ),
                                itemCount: loan.documentUrls.length,
                                itemBuilder: (context, index) {
                                  final entry = loan.documentUrls.entries
                                      .elementAt(index);
                                  final label = _getDocLabel(entry.key);

                                  return GestureDetector(
                                    onTap: () =>
                                        _viewDocument(entry.value, label),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryExtraLight,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.primary.withOpacity(
                                            0.3,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          // ✅ CachedNetworkImage
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(12),
                                                  ),
                                              child: _buildDocImage(
                                                entry.value,
                                              ),
                                            ),
                                          ),
                                          // Label
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 4,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    bottom: Radius.circular(12),
                                                  ),
                                            ),
                                            child: Text(
                                              label
                                                  .split(' ')
                                                  .skip(1)
                                                  .join(' '),
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                    color: AppColors.textWhite,
                                                    fontSize: 10,
                                                  ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Expense Records
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        '${AppStrings.expenseRecords} 📋',
                        style: AppTextStyles.heading3,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Obx(() {
                      if (_expenseController.loanExpenses.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text(
                                  '📋',
                                  style: TextStyle(fontSize: 40),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppStrings.noExpensesRecorded,
                                  style: AppTextStyles.body2,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: _expenseController.loanExpenses
                            .map((e) => ExpenseCard(expense: e))
                            .toList(),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Approve / Reject
                    if (loan.status == 'pending') ...[
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: Obx(
                          () => Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _officerController.isLoading.value
                                      ? null
                                      : _showApproveDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.check_circle,
                                    color: AppColors.textWhite,
                                  ),
                                  label: Text(
                                    AppStrings.approveLoan,
                                    style: AppTextStyles.button,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _officerController.isLoading.value
                                      ? null
                                      : _showRejectDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: AppColors.textWhite,
                                  ),
                                  label: Text(
                                    AppStrings.rejectLoan,
                                    style: AppTextStyles.button,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Alert Button
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 500),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: _showAlertDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.notifications_active,
                            color: AppColors.textWhite,
                          ),
                          label: Text(
                            AppStrings.sendAlert,
                            style: AppTextStyles.button,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAmountCard({
    required String title,
    required double amount,
    required Color color,
    required String icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            Helpers.formatCurrency(amount),
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: AppTextStyles.body2)),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
