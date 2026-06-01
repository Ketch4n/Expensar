import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../models/budget.dart';
import '../models/credit.dart';
import '../models/debt.dart';
import '../models/loan.dart';
import '../providers/data_providers.dart';
import '../services/dashboard_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletsProvider);
    final budgets = ref.watch(budgetsProvider);
    final credits = ref.watch(creditsProvider);
    final debts = ref.watch(debtsProvider);
    final loans = ref.watch(loansProvider);

    return Container(
      color: context.scaffoldBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(title: 'Statistics'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildOverviewCards(context, wallets),
                    const SizedBox(height: 20),
                    _buildSpendingTrendChart(context, wallets),
                    const SizedBox(height: 20),
                    _buildCategoryBreakdown(context, budgets, loans, credits),
                    const SizedBox(height: 20),
                    _buildDebtSummary(context, debts, loans, credits),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, List<Wallet> wallets) {
    final totalBalance = wallets.fold<double>(0, (sum, w) => sum + w.balance);
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    double monthlyIncome = 0;
    double monthlyExpenses = 0;

    for (final wallet in wallets) {
      for (final log in wallet.logs) {
        if (log.date.isAfter(startOfMonth)) {
          if (log.amount > 0) {
            monthlyIncome += log.amount;
          } else {
            monthlyExpenses += log.amount.abs();
          }
        }
      }
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                context,
                'Total Balance',
                '₱${NumberFormat('#,##0').format(totalBalance)}',
                Icons.account_balance_wallet,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                context,
                'Monthly Spend',
                '₱${NumberFormat('#,##0').format(monthlyExpenses)}',
                Icons.trending_down,
                AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                context,
                'Monthly Income',
                '₱${NumberFormat('#,##0').format(monthlyIncome)}',
                Icons.trending_up,
                AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                context,
                'Net Flow',
                '₱${NumberFormat('#,##0').format(monthlyIncome - monthlyExpenses)}',
                Icons.swap_vert,
                monthlyIncome >= monthlyExpenses
                    ? AppColors.primary
                    : AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppDecorations.cardShadow(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.subtitleColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrendChart(BuildContext context, List<Wallet> wallets) {
    final dailySpending = DashboardHelper.calculateDailySpending(
      wallets,
      days: 14,
    );
    final chartData = dailySpending;
    final maxY = chartData.every((d) => d == 0)
        ? 100.0
        : chartData.reduce((a, b) => a > b ? a : b) * 1.3;
    final now = DateTime.now();
    final days = List.generate(14, (i) {
      final day = now.subtract(Duration(days: 13 - i));
      return DateTime(day.year, day.month, day.day);
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SPENDING TREND', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 4),
          Text(
            'Last 14 days',
            style: TextStyle(fontSize: 12, color: context.subtitleColor),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: context.isDark
                        ? Colors.grey.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < 14) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('d').format(days[index]),
                              style: TextStyle(
                                fontSize: 10,
                                color: context.subtitleColor,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 13,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      chartData.length,
                      (i) => FlSpot(i.toDouble(), chartData[i]),
                    ),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context,
    List<Budget> budgets,
    List<Loan> loans,
    List<Credit> credits,
  ) {
    final categoryTotals = <String, double>{};
    for (final budget in budgets) {
      final category = budget.category.isNotEmpty ? budget.category : 'Other';
      categoryTotals[category] =
          (categoryTotals[category] ?? 0) + budget.amount;
    }

    double loanTotal = 0;
    for (final loan in loans) {
      for (final t in loan.transactions) {
        if (t.status == 'Upcoming') loanTotal += t.amountDue;
      }
    }
    if (loanTotal > 0) categoryTotals['Loans'] = loanTotal;

    double creditTotal = 0;
    for (final credit in credits) {
      if (credit.status == 'Pending') creditTotal += credit.outstandingBalance;
    }
    if (creditTotal > 0) categoryTotals['Credit Cards'] = creditTotal;

    final total = categoryTotals.values.fold<double>(0, (a, b) => a + b);
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.warning,
      AppColors.error,
      AppColors.accent,
      Color(0xFF00BCD4),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('EXPENSE BREAKDOWN', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 16),
          if (categoryTotals.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No expense data yet',
                  style: TextStyle(fontSize: 14, color: context.subtitleColor),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: categoryTotals.entries.toList().asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final category = entry.value;
                      final percentage = total > 0
                          ? (category.value / total * 100)
                          : 0.0;
                      return PieChartSectionData(
                        color: colors[index % colors.length],
                        value: category.value,
                        title: '${percentage.toStringAsFixed(0)}%',
                        radius: 30,
                        titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...categoryTotals.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final percentage = total > 0
                  ? (category.value / total * 100)
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.key[0].toUpperCase() +
                            category.key.substring(1),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '₱${NumberFormat('#,##0').format(category.value)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.subtitleColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildDebtSummary(
    BuildContext context,
    List<Debt> debts,
    List<Loan> loans,
    List<Credit> credits,
  ) {
    final totalDebt = debts.fold<double>(
      0,
      (sum, d) => sum + d.remainingBalance,
    );
    final totalLoanBalance = loans.fold<double>(0, (sum, l) => sum + l.balance);
    final totalCreditOwed = credits.fold<double>(
      0,
      (sum, c) => sum + c.outstandingBalance,
    );
    final totalOwed = totalDebt + totalLoanBalance + totalCreditOwed;
    final totalLoanPaid = loans.fold<double>(0, (sum, l) => sum + l.paidAmount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DEBT OVERVIEW', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 16),
          _debtRow(
            context,
            'Total Owed',
            '₱${NumberFormat('#,##0').format(totalOwed)}',
            AppColors.error,
          ),
          const SizedBox(height: 12),
          _debtRow(
            context,
            'Loans Remaining',
            '₱${NumberFormat('#,##0').format(totalLoanBalance)}',
            AppColors.warning,
          ),
          const SizedBox(height: 12),
          _debtRow(
            context,
            'Credit Card Balance',
            '₱${NumberFormat('#,##0').format(totalCreditOwed)}',
            AppColors.accent,
          ),
          const SizedBox(height: 12),
          _debtRow(
            context,
            'Personal Debts',
            '₱${NumberFormat('#,##0').format(totalDebt)}',
            AppColors.secondary,
          ),
          if (totalLoanPaid > 0) ...[
            Divider(height: 24, color: context.dividerColor),
            _debtRow(
              context,
              'Total Paid (Loans)',
              '₱${NumberFormat('#,##0').format(totalLoanPaid)}',
              AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _debtRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: context.subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
