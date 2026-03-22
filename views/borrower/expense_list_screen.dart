import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/expense_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final AuthController _authController = Get.find<AuthController>();
  late final ExpenseController _expenseController;

  String _selectedFilter = 'all';
  final List<Map<String, String>> _filters = [
    {'value': 'all', 'label': '📋 All'},
    {'value': 'seeds', 'label': '🌱 Seeds'},
    {'value': 'fertilizer', 'label': '🌿 Fertilizer'},
    {'value': 'pesticide', 'label': '💊 Pesticide'},
    {'value': 'equipment', 'label': '🚜 Equipment'},
    {'value': 'irrigation', 'label': '💧 Irrigation'},
    {'value': 'labor', 'label': '👨‍🌾 Labor'},
    {'value': 'fees', 'label': '🎓 Fees'},
    {'value': 'books', 'label': '📚 Books'},
    {'value': 'hostel', 'label': '🏠 Hostel'},
    {'value': 'raw_material', 'label': '🏭 Raw Material'},
    {'value': 'machinery', 'label': '⚙️ Machinery'},
    {'value': 'rent', 'label': '🏢 Rent'},
    {'value': 'salary', 'label': '💰 Salary'},
    {'value': 'food', 'label': '🍽️ Food'},
    {'value': 'transport', 'label': '🚌 Transport'},
    {'value': 'medical', 'label': '🏥 Medical'},
  ];

  @override
  void initState() {
    super.initState();
    _expenseController = Get.isRegistered<ExpenseController>()
        ? Get.find<ExpenseController>()
        : Get.put(ExpenseController());

    final uid = _authController.currentUser.value?.uid ?? '';
    if (uid.isNotEmpty) {
      _expenseController.loadUserExpenses(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ─────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back + Title
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
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Text(
                          '📋 ${AppStrings.myExpenses}',
                          style: AppTextStyles.headingWhite,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Summary Row
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: Obx(() {
                      final total = _expenseController.userExpenses.fold(
                        0.0,
                        (sum, e) => sum + e.amount,
                      );
                      final count = _expenseController.userExpenses.length;
                      return Row(
                        children: [
                          _buildHeaderStat(
                            'Total Spent',
                            Helpers.formatCurrency(total),
                            '💸',
                          ),
                          const SizedBox(width: 16),
                          _buildHeaderStat(
                            'Transactions',
                            count.toString(),
                            '📊',
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),

            // ─── Filter Chips ────────────────────────────────────
            Container(
              height: 50,
              color: AppColors.cardBackground,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter['value'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedFilter = filter['value']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        filter['label']!,
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
                },
              ),
            ),

            const Divider(height: 1),

            // ─── Expense List ─────────────────────────────────────
            Expanded(
              child: Obx(() {
                final filtered = _selectedFilter == 'all'
                    ? _expenseController.userExpenses
                    : _expenseController.userExpenses
                          .where((e) => e.category == _selectedFilter)
                          .toList();

                if (_expenseController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📋', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'all'
                              ? 'No expenses yet'
                              : 'No expenses in this category',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first expense',
                          style: AppTextStyles.body2,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Get.toNamed(AppRoutes.addExpense),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.add,
                            color: AppColors.textWhite,
                          ),
                          label: Text(
                            AppStrings.addExpense,
                            style: AppTextStyles.button,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final expense = filtered[index];
                    return FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: Duration(milliseconds: index * 50),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primaryExtraLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                _getCategoryEmoji(expense.category),
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          title: Text(
                            expense.category.toUpperCase(),
                            style: AppTextStyles.subtitle2.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                expense.description,
                                style: AppTextStyles.body2,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    expense.location,
                                    style: AppTextStyles.caption,
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    Helpers.formatDate(expense.createdAt),
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                              // Bill image indicator
                              if (expense.billImageUrl != null &&
                                  expense.billImageUrl!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.receipt,
                                      size: 12,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Bill attached',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Helpers.formatCurrency(expense.amount),
                                style: AppTextStyles.subtitle1.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (expense.billImageUrl != null &&
                                  expense.billImageUrl!.isNotEmpty)
                                GestureDetector(
                                  onTap: () =>
                                      _showBillImage(expense.billImageUrl!),
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryExtraLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'View Bill',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),

      // ─── FAB ─────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addExpense),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.textWhite),
        label: Text(AppStrings.addExpense, style: AppTextStyles.button),
      ),
    );
  }

  // ─── Show Bill Image Dialog ────────────────────────────────
  void _showBillImage(String imageUrl) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('🧾 Bill Photo', style: AppTextStyles.headingWhite),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, color: AppColors.textWhite),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 60,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 8),
                        Text('Could not load image'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.textWhite.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.subtitle2.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textWhite,
                  ),
                ),
              ],
            ),
          ],
        ),
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
