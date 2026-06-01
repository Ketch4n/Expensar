import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';
import '../providers/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtsProvider);
    final pending = debts.where((d) => d.status == 'Pending');
    final totalRemaining = pending.fold<double>(
      0,
      (sum, d) => sum + d.remainingBalance,
    );

    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Debts'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REMAINING DEBT',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₱${NumberFormat('#,##0.00').format(totalRemaining)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${pending.length} pending',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${debts.length - pending.length} paid',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: debts.isEmpty
                  ? Center(
                      child: Text(
                        'No debts yet',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: debts.length,
                      itemBuilder: (context, index) =>
                          _buildDebtCard(context, debts[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context, Debt debt) {
    final isPaid = debt.status == 'Paid';

    return GestureDetector(
      onTap: () => _showDebtDetails(context, debt),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isPaid ? AppColors.primary : AppColors.warning)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isPaid ? Icons.check_circle_outline : Icons.person_outline,
                color: isPaid ? AppColors.primary : AppColors.warning,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(debt.name, style: AppTextStyles.cardTitle),
                  Text(
                    isPaid
                        ? 'Fully paid'
                        : 'Remaining: ₱${NumberFormat('#,##0').format(debt.remainingBalance)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isPaid ? AppColors.primary : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '₱${NumberFormat('#,##0').format(debt.totalAmount)}',
              style: AppTextStyles.amountMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _showDebtDetails(BuildContext context, Debt debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(debt.name, style: AppTextStyles.heading),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: debt.status == 'Paid'
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      debt.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: debt.status == 'Paid'
                            ? AppColors.primary
                            : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: debt.logs.isEmpty
                  ? Center(
                      child: Text(
                        'No log entries',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: debt.logs.length,
                      itemBuilder: (context, index) {
                        final log = debt.logs[index];
                        final isBorrowed = log.amountBorrowed != null;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                isBorrowed
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isBorrowed
                                    ? AppColors.error
                                    : AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.description ??
                                          (isBorrowed
                                              ? 'Borrowed'
                                              : 'Payment from ${log.paymentFrom ?? ""}'),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'MMM d, yyyy',
                                      ).format(log.date),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                isBorrowed
                                    ? '+₱${NumberFormat('#,##0').format(log.amountBorrowed)}'
                                    : '-₱${NumberFormat('#,##0').format(log.amountPaid)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isBorrowed
                                      ? AppColors.error
                                      : AppColors.primary,
                                ),
                              ),
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
}
