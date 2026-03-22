import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../controllers/loan_controller.dart';
import '../../controllers/expense_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../widgets/chart_widget.dart';

class BorrowerReportScreen extends StatefulWidget {
  const BorrowerReportScreen({super.key});

  @override
  State<BorrowerReportScreen> createState() => _BorrowerReportScreenState();
}

class _BorrowerReportScreenState extends State<BorrowerReportScreen> {
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
            // ─── App Bar ───────────────────────────────
            SliverAppBar(
              expandedHeight: 180,
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
                        '📊 ${AppStrings.report}',
                        style: AppTextStyles.headingWhite,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loan.loanType.toUpperCase(),
                        style: AppTextStyles.bodyWhite,
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
                    // Summary Card
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Utilization Score',
                                  style: AppTextStyles.bodyWhite,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getScoreColor(
                                      loan.utilizationPercentage,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _getScoreColor(
                                        loan.utilizationPercentage,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _getScoreLabel(loan.utilizationPercentage),
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textWhite,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            CircularPercentIndicator(
                              radius: 70,
                              lineWidth: 12,
                              percent: (loan.utilizationPercentage / 100).clamp(
                                0.0,
                                1.0,
                              ),
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${loan.utilizationPercentage.toStringAsFixed(1)}%',
                                    style: AppTextStyles.headingWhite,
                                  ),
                                  Text('Used', style: AppTextStyles.bodyWhite),
                                ],
                              ),
                              progressColor: _getScoreColor(
                                loan.utilizationPercentage,
                              ),
                              backgroundColor: AppColors.textWhite.withOpacity(
                                0.3,
                              ),
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                            const SizedBox(height: 16),
                            // Amount Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildAmountInfo(
                                  'Total',
                                  loan.totalAmount,
                                  '💰',
                                ),
                                _buildAmountInfo('Used', loan.usedAmount, '📊'),
                                _buildAmountInfo(
                                  'Left',
                                  loan.remainingAmount,
                                  '✅',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pie Chart
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: LoanUtilizationChart(
                        usedAmount: loan.usedAmount,
                        totalAmount: loan.totalAmount,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Category Chart
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: Obx(() {
                        final categoryData = _expenseController
                            .getCategoryWiseTotal();
                        if (categoryData.isEmpty) {
                          return const SizedBox();
                        }
                        return CategoryExpenseChart(categoryData: categoryData);
                      }),
                    ),

                    const SizedBox(height: 20),

                    // Progress Bar
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
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
                              'Loan Progress',
                              style: AppTextStyles.subtitle1,
                            ),
                            const SizedBox(height: 16),
                            _buildProgressRow(
                              label: 'Amount Used',
                              value: loan.usedAmount,
                              total: loan.totalAmount,
                              color: AppColors.warning,
                            ),
                            const SizedBox(height: 12),
                            _buildProgressRow(
                              label: 'Amount Remaining',
                              value: loan.remainingAmount,
                              total: loan.totalAmount,
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Expense Summary
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 500),
                      child: Obx(() {
                        final categoryData = _expenseController
                            .getCategoryWiseTotal();
                        if (categoryData.isEmpty) {
                          return const SizedBox();
                        }
                        return Container(
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
                                'Category Summary',
                                style: AppTextStyles.subtitle1,
                              ),
                              const Divider(height: 20),
                              ...categoryData.entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        _getCategoryEmoji(entry.key),
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          entry.key.toUpperCase(),
                                          style: AppTextStyles.body2,
                                        ),
                                      ),
                                      Text(
                                        Helpers.formatCurrency(entry.value),
                                        style: AppTextStyles.subtitle2.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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

  Widget _buildAmountInfo(String label, double amount, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          Helpers.formatCurrency(amount),
          style: AppTextStyles.bodyWhite.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: AppTextStyles.bodyWhite),
      ],
    );
  }

  Widget _buildProgressRow({
    required String label,
    required double value,
    required double total,
    required Color color,
  }) {
    final percent = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.body2),
            Text(
              Helpers.formatCurrency(value),
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearPercentIndicator(
          lineHeight: 10,
          percent: percent,
          backgroundColor: AppColors.primaryExtraLight,
          progressColor: color,
          barRadius: const Radius.circular(5),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage <= 50) return Colors.greenAccent;
    if (percentage <= 80) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _getScoreLabel(double percentage) {
    if (percentage <= 50) return '✅ Good';
    if (percentage <= 80) return '⚠️ Warning';
    return '🚨 Alert';
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'seeds':
        return '🌱';
      case 'fertilizer':
        return '🌿';
      case 'pesticide':
        return '💊';
      case 'equipment':
        return '🚜';
      case 'irrigation':
        return '💧';
      case 'labor':
        return '👨‍🌾';
      case 'fees':
        return '🎓';
      case 'books':
        return '📚';
      case 'hostel':
        return '🏠';
      case 'raw_material':
        return '🏭';
      case 'machinery':
        return '⚙️';
      case 'rent':
        return '🏢';
      case 'salary':
        return '💰';
      case 'marketing':
        return '📢';
      case 'food':
        return '🍽️';
      case 'transport':
        return '🚌';
      case 'medical':
        return '🏥';
      default:
        return '📦';
    }
  }
}
