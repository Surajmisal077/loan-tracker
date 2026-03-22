import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/loan_controller.dart';
import '../../controllers/officer_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';

class OfficerDashboard extends StatefulWidget {
  const OfficerDashboard({super.key});

  @override
  State<OfficerDashboard> createState() => _OfficerDashboardState();
}

class _OfficerDashboardState extends State<OfficerDashboard> {
  final AuthController _authController = Get.find<AuthController>();
  late final LoanController _loanController;
  late final OfficerController _officerController;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loanController = Get.isRegistered<LoanController>()
        ? Get.find<LoanController>()
        : Get.put(LoanController());

    _officerController = Get.isRegistered<OfficerController>()
        ? Get.find<OfficerController>()
        : Get.put(OfficerController());

    _loanController.loadAllLoans();
    _officerController.loadAllBorrowers();
  }

  // ─── Back Press Handler ✅ Updated ────────────────────────
  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }
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
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildBorrowersTab();
      case 2:
        return _buildLoansTab();
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
                    Text('Hello Officer 👋', style: AppTextStyles.body2),
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
              () => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard(
                    title: 'Total Borrowers',
                    value: _officerController.totalBorrowers.toString(),
                    icon: '👥',
                    color: AppColors.primary,
                  ),
                  _buildStatCard(
                    title: 'Total Loans',
                    value: _officerController.totalLoans.toString(),
                    icon: '💳',
                    color: AppColors.info,
                  ),
                  _buildStatCard(
                    title: 'Pending',
                    value: _officerController.pendingLoans.toString(),
                    icon: '⏳',
                    color: AppColors.warning,
                  ),
                  _buildStatCard(
                    title: 'Approved',
                    value: _officerController.approvedLoans.toString(),
                    icon: '✅',
                    color: AppColors.success,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 300),
            child: Obx(
              () => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('💰', style: TextStyle(fontSize: 40)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Disbursed', style: AppTextStyles.bodyWhite),
                        Text(
                          Helpers.formatCurrency(
                            _officerController.totalDisbursedAmount,
                          ),
                          style: AppTextStyles.headingWhite,
                        ),
                      ],
                    ),
                  ],
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
                Text('⏳ Pending Loans', style: AppTextStyles.heading3),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 2),
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
            final pendingLoans = _loanController.allLoans
                .where((l) => l.status == 'pending')
                .take(3)
                .toList();

            if (pendingLoans.isEmpty) {
              return _buildEmptyState(
                '✅',
                'No pending loans',
                'All loans are processed',
              );
            }

            return Column(
              children: pendingLoans.map((loan) {
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
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('⏳', style: TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loan.userName,
                              style: AppTextStyles.subtitle2.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              loan.loanType.toUpperCase(),
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Helpers.formatCurrency(loan.totalAmount),
                            style: AppTextStyles.subtitle2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              _loanController.selectLoan(loan);
                              Get.toNamed(AppRoutes.loanApproval);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Review',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── Borrowers Tab ────────────────────────────────────────
  Widget _buildBorrowersTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.allBorrowers, style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (_officerController.allBorrowers.isEmpty) {
                return _buildEmptyState(
                  '👥',
                  'No borrowers yet',
                  'Borrowers will appear here',
                );
              }
              return ListView.builder(
                itemCount: _officerController.allBorrowers.length,
                itemBuilder: (context, index) {
                  final borrower = _officerController.allBorrowers[index];
                  final loans = _officerController.getBorrowerLoans(
                    borrower.uid,
                  );
                  return GestureDetector(
                    onTap: () {
                      _officerController.selectBorrower(borrower);
                      Get.toNamed(AppRoutes.borrowerDetail);
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
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryExtraLight,
                              image:
                                  borrower.profileImage != null &&
                                      borrower.profileImage!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        borrower.profileImage!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child:
                                borrower.profileImage == null ||
                                    borrower.profileImage!.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  borrower.fullName,
                                  style: AppTextStyles.subtitle1,
                                ),
                                Text(
                                  borrower.email,
                                  style: AppTextStyles.caption,
                                ),
                                Text(
                                  '${loans.length} loan(s)',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                  ),
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

  // ─── Loans Tab ────────────────────────────────────────────
  Widget _buildLoansTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All Loans 💳', style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (_loanController.allLoans.isEmpty) {
                return _buildEmptyState(
                  '💳',
                  'No loans yet',
                  'Loans will appear here',
                );
              }
              return ListView.builder(
                itemCount: _loanController.allLoans.length,
                itemBuilder: (context, index) {
                  final loan = _loanController.allLoans[index];
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
                                _getLoanEmoji(loan.loanType),
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
                                  loan.userName,
                                  style: AppTextStyles.subtitle2.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  loan.loanType.toUpperCase(),
                                  style: AppTextStyles.caption,
                                ),
                                Text(
                                  Helpers.formatDate(loan.createdAt),
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Helpers.formatCurrency(loan.totalAmount),
                                style: AppTextStyles.subtitle2.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Helpers.getStatusColor(
                                    loan.status,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  loan.status.toUpperCase(),
                                  style: AppTextStyles.caption.copyWith(
                                    color: Helpers.getStatusColor(loan.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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

  // ─── Report Tab ───────────────────────────────────────────
  Widget _buildReportTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📊 ${AppStrings.report}', style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (_officerController.allBorrowers.isEmpty) {
                return _buildEmptyState(
                  '📊',
                  'No data yet',
                  'Reports will appear here',
                );
              }
              return ListView.builder(
                itemCount: _officerController.allBorrowers.length,
                itemBuilder: (context, index) {
                  final borrower = _officerController.allBorrowers[index];
                  final loans = _officerController.getBorrowerLoans(
                    borrower.uid,
                  );
                  return GestureDetector(
                    onTap: () {
                      _officerController.selectBorrower(borrower);
                      Get.toNamed(AppRoutes.officerReport);
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
                                  borrower.fullName,
                                  style: AppTextStyles.subtitle1,
                                ),
                                Text(
                                  '${loans.length} loan(s)',
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
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Borrowers'),
        BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Loans'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
      ],
    );
  }

  // ─── Helper Widgets ───────────────────────────────────────
  Widget _buildStatCard({
    required String title,
    required String value,
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
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyles.heading2.copyWith(color: color),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(title, style: AppTextStyles.caption),
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
