import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../models/budget.dart';
import '../models/credit.dart';
import '../models/debt.dart';
import '../models/loan.dart';
import '../services/database_service.dart';
import '../services/dashboard_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Wallet> _wallets = [];
  List<Budget> _budgets = [];
  List<Credit> _credits = [];
  List<Debt> _debts = [];
  List<Loan> _loans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final wallets = await DatabaseService.getWallets();
    final budgets = await DatabaseService.getBudgets();
    final credits = await DatabaseService.getCredits();
    final debts = await DatabaseService.getDebts();
    final loans = await DatabaseService.getLoans();
    if (!mounted) return;
    setState(() {
      _wallets = wallets;
      _budgets = budgets;
      _credits = credits;
      _debts = debts;
      _loans = loans;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Statistics'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildOverviewCards(),
                    const SizedBox(height: 20),
                    _buildSpendingTrendChart(),
                    const SizedBox(height: 20),
                    _buildCategoryBreakdown(),
                    const SizedBox(height: 20),
                    _buildDebtSummary(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    final totalBalance = _wallets.fold<double>(0, (sum, w) => sum + w.balance);
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    double monthlyIncome = 0;
    double monthlyExpenses = 0;

    for (final wallet in _wallets) {
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
                'Total Balance',
                '₱${NumberFormat('#,##0').format(totalBalance)}',
                Icons.account_balance_wallet,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
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
                'Monthly Income',
                '₱${NumberFormat('#,##0').format(monthlyIncome)}',
                Icons.trending_up,
                AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
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

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppDecorations.cardShadow],
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
              color: Colors.grey[500],
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrendChart() {
    final dailySpending = DashboardHelper.calculateDailySpending(
      _wallets,
      days: 14,
    );
    final chartData = dailySpending.every((d) => d == 0)
        ? [
            150.0,
            280.0,
            180.0,
            320.0,
            220.0,
            180.0,
            469.0,
            350.0,
            200.0,
            420.0,
            150.0,
            300.0,
            250.0,
            380.0,
          ]
        : dailySpending;
    final maxY = chartData.reduce((a, b) => a > b ? a : b) * 1.3;
    final now = DateTime.now();
    final days = List.generate(14, (i) {
      final day = now.subtract(Duration(days: 13 - i));
      return DateTime(day.year, day.month, day.day);
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SPENDING TREND', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 4),
          Text(
            'Last 14 days',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
                    color: Colors.grey.withValues(alpha: 0.1),
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
                                color: Colors.grey[400],
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

  Widget _buildCategoryBreakdown() {
    final categoryTotals = <String, double>{};
    for (final budget in _budgets) {
      final category = budget.category.isNotEmpty ? budget.category : 'Other';
      categoryTotals[category] =
          (categoryTotals[category] ?? 0) + budget.amount;
    }

    double loanTotal = 0;
    for (final loan in _loans) {
      for (final t in loan.transactions) {
        if (t.status == 'Upcoming') loanTotal += t.amountDue;
      }
    }
    if (loanTotal > 0) categoryTotals['Loans'] = loanTotal;

    double creditTotal = 0;
    for (final credit in _credits) {
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
      decoration: AppDecorations.card(),
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
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
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
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '₱${NumberFormat('#,##0').format(category.value)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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

  Widget _buildDebtSummary() {
    final totalDebt = _debts.fold<double>(
      0,
      (sum, d) => sum + d.remainingBalance,
    );
    final totalLoanBalance = _loans.fold<double>(
      0,
      (sum, l) => sum + l.balance,
    );
    final totalCreditOwed = _credits.fold<double>(
      0,
      (sum, c) => sum + c.outstandingBalance,
    );
    final totalOwed = totalDebt + totalLoanBalance + totalCreditOwed;
    final totalLoanPaid = _loans.fold<double>(
      0,
      (sum, l) => sum + l.paidAmount,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DEBT OVERVIEW', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 16),
          _debtRow(
            'Total Owed',
            '₱${NumberFormat('#,##0').format(totalOwed)}',
            AppColors.error,
          ),
          const SizedBox(height: 12),
          _debtRow(
            'Loans Remaining',
            '₱${NumberFormat('#,##0').format(totalLoanBalance)}',
            AppColors.warning,
          ),
          const SizedBox(height: 12),
          _debtRow(
            'Credit Card Balance',
            '₱${NumberFormat('#,##0').format(totalCreditOwed)}',
            AppColors.accent,
          ),
          const SizedBox(height: 12),
          _debtRow(
            'Personal Debts',
            '₱${NumberFormat('#,##0').format(totalDebt)}',
            AppColors.secondary,
          ),
          if (totalLoanPaid > 0) ...[
            const Divider(height: 24),
            _debtRow(
              'Total Paid (Loans)',
              '₱${NumberFormat('#,##0').format(totalLoanPaid)}',
              AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _debtRow(String label, String value, Color color) {
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
              color: Colors.grey[600],
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
