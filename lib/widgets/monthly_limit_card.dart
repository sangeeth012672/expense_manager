import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class MonthlyLimitCard extends StatelessWidget {
  final double currentSpend;
  final double limit;

  const MonthlyLimitCard({
    Key? key,
    required this.currentSpend,
    required this.limit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = (currentSpend / limit).clamp(0.0, 1.0);
    bool isOverLimit = currentSpend > limit;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'You Spend',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₹${limit.toInt()}',
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${currentSpend.toInt()}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverLimit ? AppColors.expense : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
