import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../controllers/loan_controller.dart';
import '../../controllers/officer_controller.dart';
import '../../controllers/expense_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';
import '../widgets/chart_widget.dart';

class OfficerReportScreen extends StatefulWidget {
  const OfficerReportScreen({super.key});

  @override
  State<OfficerReportScreen> createState() => _OfficerReportScreenState();
}

class _OfficerReportScreenState extends State<OfficerReportScreen> {
  final OfficerController _officerController = Get.find<OfficerController>();
  final LoanController _loanController = Get.find<LoanController>();
  late final ExpenseController _expenseController;

  @override
  void initState() {
    super.initState();
    _expenseController = Get.isRegistered<ExpenseController>()
        ? Get.find<ExpenseController>()
        : Get.put(ExpenseController());

    // Borrower चे expenses load कर
    final borrower = _officerController.selectedBorrower.value;
    if (borrower != null) {
      _expenseController.loadUserExpenses(borrower.uid);
    }
  }

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
        final totalAmount = loans.fold(0.0, (sum, l) => sum + l.totalAmount);
        final usedAmount = loans.fold(0.0, (sum, l) => sum + l.usedAmount);
        final remainingAmount = totalAmount - usedAmount;
        final overallUtilization = Helpers.calculateUtilization(
          usedAmount,
          totalAmount,
        );

        return CustomScrollView(
          slivers: [
            // ─── App Bar ───────────────────────────────
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
                        '📊 ${AppStrings.report}',
                        style: AppTextStyles.headingWhite,
                      ),
                      const SizedBox(height: 4),
                      Text(borrower.fullName, style: AppTextStyles.bodyWhite),
                      const SizedBox(height: 4),
                      Text(
                        borrower.email,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textWhite.withOpacity(0.8),
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
                    // ─── Overall Summary Card ───────────
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
                                  'Overall Utilization',
                                  style: AppTextStyles.bodyWhite,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getScoreColor(
                                      overallUtilization,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _getScoreColor(overallUtilization),
                                    ),
                                  ),
                                  child: Text(
                                    _getScoreLabel(overallUtilization),
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
                              percent: (overallUtilization / 100).clamp(
                                0.0,
                                1.0,
                              ),
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${overallUtilization.toStringAsFixed(1)}%',
                                    style: AppTextStyles.headingWhite,
                                  ),
                                  Text('Used', style: AppTextStyles.bodyWhite),
                                ],
                              ),
                              progressColor: _getScoreColor(overallUtilization),
                              backgroundColor: AppColors.textWhite.withOpacity(
                                0.3,
                              ),
                              circularStrokeCap: CircularStrokeCap.round,
                            ),

                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildAmountInfo('Total', totalAmount, '💰'),
                                _buildAmountInfo('Used', usedAmount, '📊'),
                                _buildAmountInfo('Left', remainingAmount, '✅'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─── Pie Chart ──────────────────────
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: LoanUtilizationChart(
                        usedAmount: usedAmount,
                        totalAmount: totalAmount,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─── Loans Breakdown ────────────────
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'Loans Breakdown 💳',
                        style: AppTextStyles.heading3,
                      ),
                    ),

                    const SizedBox(height: 12),

                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
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
                              children: loans.map((loan) {
                                return GestureDetector(
                                  onTap: () {
                                    _loanController.selectLoan(loan);
                                    Get.toNamed(AppRoutes.loanApproval);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _getLoanTypeLabel(loan.loanType),
                                              style: AppTextStyles.subtitle1,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Helpers.getStatusColor(
                                                  loan.status,
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                loan.status.toUpperCase(),
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                      color:
                                                          Helpers.getStatusColor(
                                                            loan.status,
                                                          ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 12),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Total',
                                                  style: AppTextStyles.caption,
                                                ),
                                                Text(
                                                  Helpers.formatCurrency(
                                                    loan.totalAmount,
                                                  ),
                                                  style: AppTextStyles.subtitle1
                                                      .copyWith(
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Used',
                                                  style: AppTextStyles.caption,
                                                ),
                                                Text(
                                                  Helpers.formatCurrency(
                                                    loan.usedAmount,
                                                  ),
                                                  style: AppTextStyles.subtitle1
                                                      .copyWith(
                                                        color:
                                                            AppColors.warning,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'Remaining',
                                                  style: AppTextStyles.caption,
                                                ),
                                                Text(
                                                  Helpers.formatCurrency(
                                                    loan.remainingAmount,
                                                  ),
                                                  style: AppTextStyles.subtitle1
                                                      .copyWith(
                                                        color:
                                                            AppColors.success,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 12),

                                        LinearPercentIndicator(
                                          lineHeight: 10,
                                          percent:
                                              (loan.utilizationPercentage / 100)
                                                  .clamp(0.0, 1.0),
                                          backgroundColor:
                                              AppColors.primaryExtraLight,
                                          progressColor:
                                              Helpers.getUtilizationColor(
                                                loan.utilizationPercentage,
                                              ),
                                          barRadius: const Radius.circular(5),
                                          padding: EdgeInsets.zero,
                                        ),

                                        const SizedBox(height: 6),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              Helpers.formatDate(
                                                loan.createdAt,
                                              ),
                                              style: AppTextStyles.caption,
                                            ),
                                            Text(
                                              '${loan.utilizationPercentage.toStringAsFixed(1)}% used',
                                              style: AppTextStyles.caption.copyWith(
                                                color:
                                                    Helpers.getUtilizationColor(
                                                      loan.utilizationPercentage,
                                                    ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // ─── Alert Section ──────────────────
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: overallUtilization > 80
                              ? AppColors.error.withOpacity(0.1)
                              : overallUtilization > 50
                              ? AppColors.warning.withOpacity(0.1)
                              : AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: overallUtilization > 80
                                ? AppColors.error
                                : overallUtilization > 50
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              overallUtilization > 80
                                  ? '🚨'
                                  : overallUtilization > 50
                                  ? '⚠️'
                                  : '✅',
                              style: const TextStyle(fontSize: 30),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    overallUtilization > 80
                                        ? 'High Utilization Alert!'
                                        : overallUtilization > 50
                                        ? 'Moderate Utilization'
                                        : 'Good Utilization',
                                    style: AppTextStyles.subtitle1.copyWith(
                                      color: overallUtilization > 80
                                          ? AppColors.error
                                          : overallUtilization > 50
                                          ? AppColors.warning
                                          : AppColors.success,
                                    ),
                                  ),
                                  Text(
                                    overallUtilization > 80
                                        ? 'Borrower has used ${overallUtilization.toStringAsFixed(1)}% of loan. Consider sending alert.'
                                        : overallUtilization > 50
                                        ? 'Borrower has used ${overallUtilization.toStringAsFixed(1)}% of loan. Monitor closely.'
                                        : 'Borrower is utilizing loan properly. ${overallUtilization.toStringAsFixed(1)}% used.',
                                    style: AppTextStyles.body2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─── Expenses Section ✅ NEW ─────────
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 600),
                      child: Text(
                        'Expense Records 📋',
                        style: AppTextStyles.heading3,
                      ),
                    ),

                    const SizedBox(height: 12),

                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 700),
                      child: Obx(() {
                        final allExpenses = _expenseController.userExpenses
                            .where((e) => e.userId == borrower.uid)
                            .toList();

                        if (allExpenses.isEmpty) {
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
                                    'No expenses recorded',
                                    style: AppTextStyles.body2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: allExpenses.map((expense) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryExtraLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getCategoryEmoji(expense.category),
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense.category,
                                          style: AppTextStyles.subtitle2,
                                        ),
                                        Text(
                                          expense.description,
                                          style: AppTextStyles.caption,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          Helpers.formatDate(expense.createdAt),
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    Helpers.formatCurrency(expense.amount),
                                    style: AppTextStyles.subtitle1.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }),
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

  Widget _buildAmountInfo(String label, double amount, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          Helpers.formatCurrency(amount),
          style: AppTextStyles.bodyWhite.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textWhite),
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

  String _getLoanTypeLabel(String type) {
    switch (type) {
      case 'agriculture':
        return '🌾 Agriculture';
      case 'education':
        return '🎓 Education';
      case 'msme':
        return '🏭 MSME';
      case 'personal':
        return '👤 Personal';
      case 'home':
        return '🏠 Home';
      default:
        return '💰 Loan';
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'seeds':
        return '🌱';
      case 'fertilizer':
        return '🌿';
      case 'equipment':
        return '🔧';
      case 'fees':
        return '🎓';
      case 'books':
        return '📚';
      case 'rent':
        return '🏠';
      case 'salary':
        return '💵';
      case 'food':
        return '🍽️';
      case 'transport':
        return '🚗';
      case 'medical':
        return '💊';
      default:
        return '💰';
    }
  }
}
