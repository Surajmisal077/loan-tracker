import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/officer_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';

class BorrowerListScreen extends StatefulWidget {
  const BorrowerListScreen({super.key});

  @override
  State<BorrowerListScreen> createState() => _BorrowerListScreenState();
}

class _BorrowerListScreenState extends State<BorrowerListScreen> {
  final OfficerController _officerController = Get.find<OfficerController>();
  final RxString _searchQuery = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
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
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
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
                        child: Obx(
                          () => Text(
                            AppStrings.allBorrowers,
                            style: AppTextStyles.headingWhite,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Search Bar
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.textWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (value) => _searchQuery.value = value,
                        decoration: InputDecoration(
                          hintText: 'Search borrowers...',
                          hintStyle: AppTextStyles.body2,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── List ─────────────────────────────────
            Expanded(
              child: Obx(() {
                final borrowers = _officerController.allBorrowers
                    .where(
                      (b) =>
                          _searchQuery.value.isEmpty ||
                          b.fullName.toLowerCase().contains(
                            _searchQuery.value.toLowerCase(),
                          ) ||
                          b.email.toLowerCase().contains(
                            _searchQuery.value.toLowerCase(),
                          ),
                    )
                    .toList();

                if (borrowers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('👥', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 16),
                        Text(
                          'No borrowers found',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Borrowers will appear here',
                          style: AppTextStyles.body2,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: borrowers.length,
                  itemBuilder: (context, index) {
                    final borrower = borrowers[index];
                    final loans = _officerController.getBorrowerLoans(
                      borrower.uid,
                    );

                    return FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: Duration(milliseconds: index * 100),
                      child: GestureDetector(
                        onTap: () {
                          _officerController.selectBorrower(borrower);
                          Get.toNamed(AppRoutes.borrowerDetail);
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
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryExtraLight,
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
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
                                        size: 28,
                                      )
                                    : null,
                              ),

                              const SizedBox(width: 12),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      borrower.fullName,
                                      style: AppTextStyles.subtitle1,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      borrower.email,
                                      style: AppTextStyles.caption,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _buildLoanBadge(
                                          '${loans.where((l) => l.status == 'approved').length} ✅',
                                          AppColors.success,
                                        ),
                                        const SizedBox(width: 6),
                                        _buildLoanBadge(
                                          '${loans.where((l) => l.status == 'pending').length} ⏳',
                                          AppColors.warning,
                                        ),
                                        const SizedBox(width: 6),
                                        _buildLoanBadge(
                                          '${loans.where((l) => l.status == 'rejected').length} ❌',
                                          AppColors.error,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Total Amount
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    Helpers.formatCurrency(
                                      loans.fold(
                                        0.0,
                                        (sum, l) => sum + l.totalAmount,
                                      ),
                                    ),
                                    style: AppTextStyles.subtitle2.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                ],
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
    );
  }

  Widget _buildLoanBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
