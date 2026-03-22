import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/loan_controller.dart';
import '../../controllers/officer_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';
import '../widgets/loan_card.dart';

class BorrowerDetailScreen extends StatefulWidget {
  const BorrowerDetailScreen({super.key});

  @override
  State<BorrowerDetailScreen> createState() => _BorrowerDetailScreenState();
}

class _BorrowerDetailScreenState extends State<BorrowerDetailScreen> {
  final OfficerController _officerController = Get.find<OfficerController>();
  final LoanController _loanController = Get.find<LoanController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Obx(() {
        final borrower = _officerController.selectedBorrower.value;
        if (borrower == null) {
          return const Center(child: Text('No borrower selected'));
        }

        final loans = _officerController.getBorrowerLoans(borrower.uid);

        return CustomScrollView(
          slivers: [
            // ─── App Bar ───────────────────────────────
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),

                      // Profile Image
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryExtraLight,
                            border: Border.all(
                              color: AppColors.textWhite,
                              width: 3,
                            ),
                            image:
                                borrower.profileImage != null &&
                                    borrower.profileImage!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(borrower.profileImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child:
                              borrower.profileImage == null ||
                                  borrower.profileImage!.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 12),

                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          borrower.fullName,
                          style: AppTextStyles.headingWhite,
                        ),
                      ),

                      const SizedBox(height: 4),

                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: Text(
                          borrower.email,
                          style: AppTextStyles.bodyWhite,
                        ),
                      ),

                      const SizedBox(height: 4),

                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textWhite.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '👨‍🌾 Borrower',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Content ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contact Info Card
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
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
                              'Contact Information',
                              style: AppTextStyles.subtitle1,
                            ),
                            const Divider(height: 20),
                            _buildInfoRow(Icons.email, 'Email', borrower.email),
                            _buildInfoRow(Icons.phone, 'Phone', borrower.phone),
                            _buildInfoRow(
                              Icons.calendar_today,
                              'Member Since',
                              Helpers.formatDate(borrower.createdAt),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats Row
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Total Loans',
                              value: loans.length.toString(),
                              icon: '💳',
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Approved',
                              value: loans
                                  .where((l) => l.status == 'approved')
                                  .length
                                  .toString(),
                              icon: '✅',
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Pending',
                              value: loans
                                  .where((l) => l.status == 'pending')
                                  .length
                                  .toString(),
                              icon: '⏳',
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Total Amount
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildAmountInfo(
                              'Total Loan',
                              loans.fold(0.0, (sum, l) => sum + l.totalAmount),
                              '💰',
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppColors.textWhite.withOpacity(0.3),
                            ),
                            _buildAmountInfo(
                              'Total Used',
                              loans.fold(0.0, (sum, l) => sum + l.usedAmount),
                              '📊',
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppColors.textWhite.withOpacity(0.3),
                            ),
                            _buildAmountInfo(
                              'Remaining',
                              loans.fold(
                                0.0,
                                (sum, l) => sum + l.remainingAmount,
                              ),
                              '✅',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Loans Header
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
                      child: Obx(
                        () => Text(
                          AppStrings.myLoans,
                          style: AppTextStyles.heading3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Loans List
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 500),
                      child: loans.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    const Text(
                                      '💳',
                                      style: TextStyle(fontSize: 40),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No loans found',
                                      style: AppTextStyles.body2,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: loans
                                  .map(
                                    (loan) => LoanCard(
                                      loan: loan,
                                      onTap: () {
                                        _loanController.selectLoan(loan);
                                        Get.toNamed(AppRoutes.loanApproval);
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          SizedBox(width: 100, child: Text(label, style: AppTextStyles.body2)),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.heading2.copyWith(color: color)),
          Text(title, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildAmountInfo(String label, double amount, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          Helpers.formatCurrency(amount),
          style: AppTextStyles.bodyWhite.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textWhite),
        ),
      ],
    );
  }
}
