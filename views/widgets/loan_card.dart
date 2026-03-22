import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/helpers.dart';
import '../../models/loan_model.dart';

class LoanCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback? onTap;

  const LoanCard({super.key, required this.loan, this.onTap});

  @override
  Widget build(BuildContext context) {
    final utilization = loan.utilizationPercentage / 100;
    final statusColor = Helpers.getStatusColor(loan.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLoanTypeLabel(loan.loanType),
                        style: AppTextStyles.subtitle1.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Helpers.formatDate(loan.createdAt),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textWhite.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
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

              const SizedBox(height: 16),

              // Amount Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textWhite.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        Helpers.formatCurrency(loan.totalAmount),
                        style: AppTextStyles.amountWhite,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Remaining',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textWhite.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        Helpers.formatCurrency(loan.remainingAmount),
                        style: AppTextStyles.headingWhite.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress Bar
              LinearPercentIndicator(
                lineHeight: 10,
                percent: utilization.clamp(0.0, 1.0),
                backgroundColor: AppColors.textWhite.withOpacity(0.3),
                progressColor: _getProgressColor(loan.utilizationPercentage),
                barRadius: const Radius.circular(5),
                padding: EdgeInsets.zero,
              ),

              const SizedBox(height: 8),

              // Percentage Text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Used: ${Helpers.formatCurrency(loan.usedAmount)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textWhite.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '${loan.utilizationPercentage.toStringAsFixed(1)}% used',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage <= 50) return Colors.greenAccent;
    if (percentage <= 80) return Colors.orangeAccent;
    return Colors.redAccent;
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
