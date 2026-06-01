import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/credit.dart';
import '../providers/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

class CreditsScreen extends ConsumerWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credits = ref.watch(creditsProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Credits'),
            Expanded(
              child: credits.isEmpty
                  ? Center(
                      child: Text(
                        'No credits yet',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: credits.length,
                      itemBuilder: (context, index) =>
                          _buildCreditCard(credits[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCard(Credit credit) {
    final usagePercent = credit.outstandingBalance / credit.creditLimit;
    final daysLeft = credit.dueDate.difference(DateTime.now()).inDays;

    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppDecorations.cardShadow(context)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: AppColors.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credit.name,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        'Limit: ₱${NumberFormat('#,##0').format(credit.creditLimit)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: credit.status == 'Paid'
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    credit.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: credit.status == 'Paid'
                          ? AppColors.primary
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Outstanding',
                  style: TextStyle(fontSize: 11, color: context.subtitleColor),
                ),
                Text(
                  '₱${NumberFormat('#,##0.00').format(credit.outstandingBalance)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: usagePercent.clamp(0.0, 1.0),
                backgroundColor: context.isDark
                    ? Colors.grey[700]
                    : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  usagePercent > 0.8 ? AppColors.error : AppColors.accent,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available: ₱${NumberFormat('#,##0.00').format(credit.availableCredit)}',
                  style: TextStyle(fontSize: 11, color: context.subtitleColor),
                ),
                if (daysLeft >= 0)
                  Text(
                    'Due in $daysLeft days',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: daysLeft <= 7
                          ? AppColors.error
                          : context.subtitleColor,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
