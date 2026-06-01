import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../providers/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);
    final bills = budgets.where((b) => b.category == 'budget').toList();
    final subs = budgets.where((b) => b.category == 'subscription').toList();

    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Bills & Subscriptions'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (bills.isNotEmpty) ...[
                      const Text('BILLS', style: AppTextStyles.sectionLabel),
                      const SizedBox(height: 12),
                      ...bills.map(_buildBudgetItem),
                      const SizedBox(height: 24),
                    ],
                    if (subs.isNotEmpty) ...[
                      const Text(
                        'SUBSCRIPTIONS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...subs.map(_buildBudgetItem),
                    ],
                    if (budgets.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text(
                            'No bills or subscriptions yet',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetItem(Budget budget) {
    final daysLeft = budget.dueDate.difference(DateTime.now()).inDays;
    final isSub = budget.category == 'subscription';
    final color = isSub ? AppColors.accent : AppColors.secondary;

    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppDecorations.cardShadow(context)],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSub ? Icons.subscriptions : Icons.receipt_outlined,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    budget.name,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  if (budget.description != null)
                    Text(
                      budget.description!,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.subtitleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    DateFormat('MMM d').format(budget.dueDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  budget.amount > 0
                      ? '₱${NumberFormat('#,##0.00').format(budget.amount)}'
                      : 'Free',
                  style: AppTextStyles.amountMedium.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                if (daysLeft >= 0)
                  Text(
                    '$daysLeft days',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: daysLeft <= 3
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
