import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/loan_controller.dart';
import '../../controllers/expense_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';
import '../widgets/loan_card.dart';

class BorrowerDashboard extends StatefulWidget {
  const BorrowerDashboard({super.key});

  @override
  State<BorrowerDashboard> createState() => _BorrowerDashboardState();
}

class _BorrowerDashboardState extends State<BorrowerDashboard> {
  final AuthController _authController = Get.find<AuthController>();
  late final LoanController _loanController;
  late final ExpenseController _expenseController;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loanController = Get.isRegistered<LoanController>()
        ? Get.find<LoanController>()
        : Get.put(LoanController());

    _expenseController = Get.isRegistered<ExpenseController>()
        ? Get.find<ExpenseController>()
        : Get.put(ExpenseController());

    final uid = _authController.currentUser.value?.uid ?? '';
    if (uid.isNotEmpty) {
      _loanController.loadUserLoans(uid);
      _expenseController.loadUserExpenses(uid);
    }
  }

  // ─── Back Press Handler ✅ Updated ────────────────────────
  Future<bool> _onWillPop() async {
    // Home Tab वर नसेल तर Home Tab वर जा
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }

    // Home Tab वर असेल तर Exit dialog दाखव
    Get.defaultDialog(
      title: '🚪 Exit App?',
      middleText: 'Are you sure you want to exit the app?',
      textConfirm: 'Yes, Exit',
      textCancel: 'No',
      confirmTextColor: AppColors.textWhite,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        SystemNavigator.pop();
      },
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(child: _buildBody()),
        bottomNavigationBar: _buildBottomNav(),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton.extended(
                onPressed: () => Get.toNamed(AppRoutes.addExpense),
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add, color: AppColors.textWhite),
                label: Text(AppStrings.addExpense, style: AppTextStyles.button),
              )
            : null,
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildLoansTab();
      case 2:
        return _buildExpensesTab();
      case 3:
        return _buildReportTab();
      default:
        return _buildHomeTab();
    }
  }

  // ─── Home Tab ─────────────────────────────────────────────
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, 👋', style: AppTextStyles.body2),
                    Obx(
                      () => Text(
                        _authController.displayName,
                        style: AppTextStyles.heading2,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.profile),
                  child: Obx(() {
                    final image = _authController.profileImage;
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryExtraLight,
                        border: Border.all(color: AppColors.primary, width: 2),
                        image: image.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(image),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: image.isEmpty
                          ? const Icon(Icons.person, color: AppColors.primary)
                          : null,
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          FadeInLeft(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Loan',
                      amount: _loanController.totalLoanAmount,
                      icon: '💰',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Used',
                      amount: _loanController.totalUsedAmount,
                      icon: '📊',
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Remaining',
                      amount: _loanController.totalRemainingAmount,
                      icon: '✅',
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          FadeInLeft(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 300),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildStatusCard(
                      label: 'Approved',
                      count: _loanController.approvedLoansCount,
                      color: AppColors.success,
                      icon: '✅',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusCard(
                      label: 'Pending',
                      count: _loanController.pendingLoansCount,
                      color: AppColors.warning,
                      icon: '⏳',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 350),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.applyLoan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
                icon: const Icon(
                  Icons.add_card,
                  color: AppColors.textWhite,
                  size: 22,
                ),
                label: Text(
                  '+ Apply for New Loan',
                  style: AppTextStyles.button.copyWith(fontSize: 16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 400),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.myLoans, style: AppTextStyles.heading3),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 1),
                  child: Text(
                    'See All',
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Obx(() {
            if (_loanController.userLoans.isEmpty) {
              return _buildEmptyState(
                '💳',
                'No loans yet',
                'Tap "Apply for New Loan" to get started!',
              );
            }
            return Column(
              children: _loanController.userLoans
                  .take(2)
                  .map(
                    (loan) => LoanCard(
                      loan: loan,
                      onTap: () {
                        _loanController.selectLoan(loan);
                        Get.toNamed(AppRoutes.loanDetail);
                      },
                    ),
                  )
                  .toList(),
            );
          }),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── Loans Tab ────────────────────────────────────────────
  Widget _buildLoansTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.myLoans, style: AppTextStyles.heading2),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.applyLoan),
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
                        'Apply',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (_loanController.userLoans.isEmpty) {
                return _buildEmptyState(
                  '💳',
                  'No loans yet',
                  'Tap Apply to request a new loan',
                );
              }
              return ListView.builder(
                itemCount: _loanController.userLoans.length,
                itemBuilder: (context, index) {
                  final loan = _loanController.userLoans[index];
                  return LoanCard(
                    loan: loan,
                    onTap: () {
                      _loanController.selectLoan(loan);
                      Get.toNamed(AppRoutes.loanDetail);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Expenses Tab ─────────────────────────────────────────
  Widget _buildExpensesTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.myExpenses, style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (_expenseController.userExpenses.isEmpty) {
                return _buildEmptyState(
                  '📋',
                  'No expenses yet',
                  'Add your first expense',
                );
              }
              return ListView.builder(
                itemCount: _expenseController.userExpenses.length,
                itemBuilder: (context, index) {
                  final expense = _expenseController.userExpenses[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense.category.toUpperCase(),
                                style: AppTextStyles.subtitle2.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                expense.description,
                                style: AppTextStyles.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                Helpers.formatDate(expense.createdAt),
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Helpers.formatCurrency(expense.amount),
                          style: AppTextStyles.subtitle1.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Report Tab ───────────────────────────────────────────
  Widget _buildReportTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.report, style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (_loanController.userLoans.isEmpty) {
                return _buildEmptyState(
                  '📊',
                  'No report yet',
                  'Add loans and expenses to see report',
                );
              }
              return ListView.builder(
                itemCount: _loanController.userLoans.length,
                itemBuilder: (context, index) {
                  final loan = _loanController.userLoans[index];
                  return GestureDetector(
                    onTap: () {
                      _loanController.selectLoan(loan);
                      Get.toNamed(AppRoutes.borrowerReport);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text('📊', style: TextStyle(fontSize: 30)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loan.loanType.toUpperCase(),
                                  style: AppTextStyles.subtitle1,
                                ),
                                Text(
                                  '${loan.utilizationPercentage.toStringAsFixed(1)}% utilized',
                                  style: AppTextStyles.body2,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Navigation ────────────────────────────────────
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor: AppColors.cardBackground,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Loans'),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Expenses',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Report'),
      ],
    );
  }

  // ─── Helper Widgets ───────────────────────────────────────
  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required String icon,
    required Color color,
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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Helpers.formatCurrency(amount),
              style: AppTextStyles.subtitle2.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Text(title, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String label,
    required int count,
    required Color color,
    required String icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: AppTextStyles.heading2.copyWith(color: color),
              ),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String emoji, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
