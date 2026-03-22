import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../controllers/loan_controller.dart';
import '../../controllers/expense_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';
import '../widgets/expense_card.dart';
import '../widgets/chart_widget.dart';

class LoanDetailScreen extends StatefulWidget {
  const LoanDetailScreen({super.key});

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  final LoanController _loanController = Get.find<LoanController>();
  late final ExpenseController _expenseController;

  @override
  void initState() {
    super.initState();
    _expenseController = Get.isRegistered<ExpenseController>()
        ? Get.find<ExpenseController>()
        : Get.put(ExpenseController());

    final loanId = _loanController.selectedLoan.value?.loanId ?? '';
    if (loanId.isNotEmpty) {
      _expenseController.loadLoanExpenses(loanId);
    }
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
                        _getLoanTypeLabel(loan.loanType),
                        style: AppTextStyles.headingWhite,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Helpers.formatDate(loan.createdAt),
                        style: AppTextStyles.bodyWhite,
                      ),
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
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildAmountCard(
                              title: AppStrings.loanAmount,
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

                    const SizedBox(height: 20),

                    // Progress
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
                                  'Loan Utilization',
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

                    const SizedBox(height: 20),

                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: LoanUtilizationChart(
                        usedAmount: loan.usedAmount,
                        totalAmount: loan.totalAmount,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Loan Info
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
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
                              'Loan Information',
                              style: AppTextStyles.subtitle1,
                            ),
                            const Divider(height: 20),
                            _buildInfoRow('🎯 Purpose', loan.purpose),
                            _buildInfoRow(
                              '📅 Date',
                              Helpers.formatDate(loan.createdAt),
                            ),
                            _buildInfoRow(
                              '🏷️ Type',
                              _getLoanTypeLabel(loan.loanType),
                            ),
                            if (loan.officerNote != null &&
                                loan.officerNote!.isNotEmpty)
                              _buildInfoRow(
                                '📝 Officer Note',
                                loan.officerNote!,
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Expenses Header
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.myExpenses,
                            style: AppTextStyles.heading3,
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.addExpense),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.add,
                                    color: AppColors.textWhite,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppStrings.addExpense,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Obx(() {
                      if (_expenseController.loanExpenses.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text('📋', style: TextStyle(fontSize: 40)),
                                SizedBox(height: 8),
                                Text('No expenses yet'),
                              ],
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: _expenseController.loanExpenses
                            .map((expense) => ExpenseCard(expense: expense))
                            .toList(),
                      );
                    }),

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
          SizedBox(width: 120, child: Text(label, style: AppTextStyles.body2)),
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

  String _getLoanTypeLabel(String type) {
    switch (type) {
      case 'agriculture':
        return '🌾 Agriculture Loan';
      case 'education':
        return '🎓 Education Loan';
      case 'msme':
        return '🏭 MSME Loan';
      case 'personal':
        return '👤 Personal Loan';
      case 'home':
        return '🏠 Home Loan';
      default:
        return '💰 Loan';
    }
  }
}
