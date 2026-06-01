import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class PaydayCard extends StatelessWidget {
  final int daysUntilPayday;
  final double amount;
  final DateTime paydayDate;

  const PaydayCard({
    super.key,
    required this.daysUntilPayday,
    required this.amount,
    required this.paydayDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.isDark
            ? AppColors.primary.withValues(alpha: 0.1)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppDecorations.cardShadow(context)],
        border: context.isDark
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Text('📅', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAYS UNTIL PAYDAY',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.subtitleColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$daysUntilPayday days',
                  style: AppTextStyles.amountLarge.copyWith(
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₱${NumberFormat('#,##0.00').format(amount)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM d').format(paydayDate),
                style: TextStyle(fontSize: 12, color: context.subtitleColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
