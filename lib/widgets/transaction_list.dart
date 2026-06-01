import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final incomeTransactions = transactions
        .where((t) => t.type == TransactionType.income)
        .toList();
    final expenseTransactions = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Upcoming',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Planned and recurring money moves',
            style: TextStyle(fontSize: 13, color: context.subtitleColor),
          ),
          const SizedBox(height: 20),

          // Income Section
          if (incomeTransactions.isNotEmpty) ...[
            const Text('INCOME', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 12),
            ...incomeTransactions.map(_buildTransactionItem),
            const SizedBox(height: 20),
          ],

          // Expenses Section
          if (expenseTransactions.isNotEmpty) ...[
            const Text(
              'EXPENSES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            ...expenseTransactions.map(_buildTransactionItem),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  transaction.color?.withValues(alpha: 0.1) ?? Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: _buildIcon(transaction)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title, style: AppTextStyles.cardTitle),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d').format(transaction.date),
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₱${NumberFormat('#,##0.00').format(transaction.amount)}',
                style: AppTextStyles.amountMedium,
              ),
              if (transaction.daysLeft != null) ...[
                const SizedBox(height: 2),
                Text(
                  '${transaction.daysLeft} DAYS LEFT',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(Transaction transaction) {
    final icon = transaction.icon;
    if (icon != null && icon.length == 1 && icon.codeUnitAt(0) >= 65) {
      return Text(
        icon,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: transaction.color ?? Colors.grey[700],
        ),
      );
    }
    return Text(icon ?? '💰', style: const TextStyle(fontSize: 24));
  }
}
