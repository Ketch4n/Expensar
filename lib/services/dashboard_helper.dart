import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../models/budget.dart';
import '../models/credit.dart';
import '../models/loan.dart';

/// Extracts business logic from DashboardScreen for cleaner separation.
class DashboardHelper {
  const DashboardHelper._();

  /// Calculate daily spending from wallet logs over the last [days] days.
  static List<double> calculateDailySpending(
    List<Wallet> wallets, {
    int days = 7,
  }) {
    final now = DateTime.now();
    final periodDays = List.generate(days, (i) {
      final day = now.subtract(Duration(days: days - 1 - i));
      return DateTime(day.year, day.month, day.day);
    });

    final dailySpending = List<double>.filled(days, 0);
    for (final wallet in wallets) {
      for (final log in wallet.logs) {
        final logDay = DateTime(log.date.year, log.date.month, log.date.day);
        for (int i = 0; i < days; i++) {
          if (logDay == periodDays[i] && _isOutflow(log.description)) {
            dailySpending[i] += log.amount;
          }
        }
      }
    }
    return dailySpending;
  }

  /// Determine the next payday given recurring pay days (e.g. [15, 30]).
  static DateTime getNextPayday(List<int> payDays, DateTime now) {
    final sorted = List<int>.from(payDays)..sort();
    final today = DateTime(now.year, now.month, now.day);

    for (final day in sorted) {
      final candidate = DateTime(now.year, now.month, day);
      if (candidate.isAfter(today)) return candidate;
    }

    return now.month == 12
        ? DateTime(now.year + 1, 1, sorted.first)
        : DateTime(now.year, now.month + 1, sorted.first);
  }

  /// Build upcoming income transactions from wallets.
  static List<Transaction> buildIncomeTransactions(List<Wallet> wallets) {
    final now = DateTime.now();
    final transactions = <Transaction>[];

    for (final wallet in wallets) {
      if (wallet.isRecurring && wallet.payDays.isNotEmpty) {
        final nextPayday = getNextPayday(wallet.payDays, now);
        final daysLeft = nextPayday.difference(now).inDays;
        double salaryAmount = 0;
        final salaryLogs = wallet.logs.where(
          (l) => l.description.toLowerCase().contains('salary'),
        );
        if (salaryLogs.isNotEmpty) {
          salaryAmount = salaryLogs.first.amount / 2;
        }
        transactions.add(
          Transaction(
            id: '${wallet.id}_salary',
            title: '${wallet.name} Salary',
            amount: salaryAmount,
            date: nextPayday,
            type: TransactionType.income,
            icon: '💼',
            color: Colors.green,
            daysLeft: daysLeft < 0 ? null : daysLeft,
          ),
        );
      } else if (wallet.status == 'Upcoming' &&
          wallet.expectedPayoutDate != null) {
        final daysLeft = wallet.expectedPayoutDate!.difference(now).inDays;
        transactions.add(
          Transaction(
            id: '${wallet.id}',
            title: wallet.name,
            amount: wallet.balance,
            date: wallet.expectedPayoutDate!,
            type: TransactionType.income,
            icon: '💰',
            color: Colors.teal,
            daysLeft: daysLeft < 0 ? null : daysLeft,
          ),
        );
      }
    }
    return transactions;
  }

  /// Build upcoming expense transactions from budgets, loans, and credits.
  static List<Transaction> buildExpenseTransactions(
    List<Budget> budgets,
    List<Loan> loans,
    List<Credit> credits,
  ) {
    final now = DateTime.now();
    final transactions = <Transaction>[];

    for (final budget in budgets) {
      if (budget.status == 'Upcoming') {
        final daysLeft = budget.dueDate.difference(now).inDays;
        final (icon, color) = _budgetIconAndColor(budget.name);
        transactions.add(
          Transaction(
            id: '${budget.id}',
            title: budget.name,
            amount: budget.amount,
            date: budget.dueDate,
            type: TransactionType.expense,
            icon: icon,
            color: color,
            daysLeft: daysLeft < 0 ? null : daysLeft,
          ),
        );
      }
    }

    for (final loan in loans) {
      final upcoming =
          loan.transactions.where((t) => t.status == 'Upcoming').toList()
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      if (upcoming.isNotEmpty) {
        final next = upcoming.first;
        final daysLeft = next.dueDate.difference(now).inDays;
        transactions.add(
          Transaction(
            id: '${loan.id}_${next.month}',
            title: loan.name,
            amount: next.amountDue,
            date: next.dueDate,
            type: TransactionType.expense,
            icon: '🏦',
            color: Colors.red,
            daysLeft: daysLeft < 0 ? null : daysLeft,
          ),
        );
      }
    }

    for (final credit in credits) {
      if (credit.status == 'Pending') {
        final daysLeft = credit.dueDate.difference(now).inDays;
        transactions.add(
          Transaction(
            id: '${credit.id}',
            title: credit.name,
            amount: credit.outstandingBalance,
            date: credit.dueDate,
            type: TransactionType.expense,
            icon: '💳',
            color: const Color(0xFF7C4DFF),
            daysLeft: daysLeft < 0 ? null : daysLeft,
          ),
        );
      }
    }

    transactions.sort((a, b) => a.date.compareTo(b.date));
    return transactions;
  }

  static bool _isOutflow(String description) {
    final lower = description.toLowerCase();
    return lower.contains('send') ||
        lower.contains('payment') ||
        lower.contains('transfer to');
  }

  static (String, Color) _budgetIconAndColor(String name) {
    return switch (name.toLowerCase()) {
      'dito wifi' => ('📡', Colors.blue),
      'electricity bill' => ('⚡', Colors.amber),
      'canva pro' => ('C', Colors.purple),
      _ => ('📋', Colors.grey),
    };
  }
}
