import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../models/budget.dart';
import '../models/credit.dart';
import '../models/loan.dart';
import '../providers/settings_provider.dart';
import '../providers/data_providers.dart';
import '../services/dashboard_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/spending_chart.dart';
import '../widgets/payday_card.dart';
import '../widgets/transaction_list.dart';
import '../widgets/add_expense_dialog.dart';
import 'wallets_screen.dart';
import 'loans_screen.dart';
import 'credits_screen.dart';
import 'debts_screen.dart';
import 'budgets_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 1;
  late final PageController _pageController;
  bool _isNavVisible = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    _currentIndex = 1;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getGreeting(String userName) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning, $userName';
    if (hour < 17) return 'Good afternoon, $userName';
    return 'Good evening, $userName';
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        _isNavVisible = false;
      } else {
        _isNavVisible = true;
      }
    });
  }

  void _onNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_currentIndex == 2) {
      if (!_isNavVisible) setState(() => _isNavVisible = true);
      return false;
    }
    if (_currentIndex == 0) return false;

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 2 && _isNavVisible) {
        setState(() => _isNavVisible = false);
      } else if (delta < -2 && !_isNavVisible) {
        setState(() => _isNavVisible = true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: [
            const StatsScreen(),
            _buildHomePage(),
            const WalletsScreen(),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: _buildFloatingNavAndFab(),
    );
  }

  Widget _buildFloatingNavAndFab() {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      offset: _isNavVisible ? Offset.zero : const Offset(0, 1.5),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 20, bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: context.isDark
                            ? Colors.black.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: context.isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _navItem(Icons.home_rounded, 'Home', 1),
                      _navItem(Icons.wallet_rounded, 'Wallet', 2),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _showAddExpense,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: context.isDark
                        ? Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            width: 1.5,
                          )
                        : null,
                    boxShadow: context.isDark
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.primaryLight.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: context.isDark
                        ? AppColors.primaryLighter
                        : Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onNavTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isActive ? AppColors.primary : context.subtitleColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppColors.primary : context.subtitleColor,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    final wallets = ref.watch(walletsProvider);
    final budgets = ref.watch(budgetsProvider);
    final credits = ref.watch(creditsProvider);
    final loans = ref.watch(loansProvider);
    final settings = ref.watch(settingsProvider);

    final totalBalance = wallets.fold<double>(0, (sum, w) => sum + w.balance);
    final dailySpending = DashboardHelper.calculateDailySpending(wallets);
    final todayTotal = dailySpending.last;
    final weekTotal = dailySpending.fold<double>(0, (sum, d) => sum + d);
    final monthlySpending = _calculateMonthlySpending(wallets);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getGreeting(settings.userName),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                      },
                      color: context.subtitleColor,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildQuickActions(),
                  const SizedBox(height: 20),
                  _buildWalletSummary(totalBalance),
                  const SizedBox(height: 20),
                  SpendingChart(
                    data: dailySpending,
                    todayAmount: todayTotal,
                    weekTotal: weekTotal,
                    monthTotal: monthlySpending,
                  ),
                  ..._buildConditionalSections(wallets, budgets),
                  const SizedBox(height: 20),
                  _buildUpcomingTransactions(wallets, budgets, loans, credits),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConditionalSections(
    List<Wallet> wallets,
    List<Budget> budgets,
  ) {
    final widgets = <Widget>[];
    final bills = _buildUpcomingBills(budgets);
    final payday = _buildPaydayCard(wallets);

    if (bills is! SizedBox) {
      widgets.add(const SizedBox(height: 20));
      widgets.add(bills);
    }
    if (payday is! SizedBox) {
      widgets.add(const SizedBox(height: 20));
      widgets.add(payday);
    }
    return widgets;
  }

  double _calculateMonthlySpending(List<Wallet> wallets) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    double total = 0;
    for (final wallet in wallets) {
      for (final log in wallet.logs) {
        if (log.date.isAfter(startOfMonth) || log.date == startOfMonth) {
          final desc = log.description.toLowerCase();
          if (desc.contains('send') ||
              desc.contains('payment') ||
              desc.contains('transfer to')) {
            total += log.amount;
          }
        }
      }
    }
    return total;
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MANAGE', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionButton(
                Icons.account_balance_wallet,
                'Wallets',
                AppColors.primary,
                const WalletsScreen(),
              ),
              _actionButton(
                Icons.receipt_long,
                'Loans',
                AppColors.error,
                const LoansScreen(),
              ),
              _actionButton(
                Icons.credit_card,
                'Credits',
                AppColors.accent,
                const CreditsScreen(),
              ),
              _actionButton(
                Icons.people_outline,
                'Debts',
                AppColors.warning,
                const DebtsScreen(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    Color color,
    Widget screen,
  ) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
        _refreshData();
      },
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSummary(double totalBalance) {
    final isDark = context.isDark;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WalletsScreen()),
        );
        _refreshData();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: isDark ? AppColors.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL BALANCE',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.primary.withValues(alpha: 0.7)
                          : Colors.white70,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱${NumberFormat('#,##0.00').format(totalBalance)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.primaryLighter : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingBills(List<Budget> budgets) {
    final sorted = List<Budget>.from(budgets)
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (sorted.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BudgetsScreen()),
        );
        _refreshData();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.card(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('UPCOMING BILLS', style: AppTextStyles.sectionLabel),
                Text(
                  'See all →',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...sorted.take(3).map((budget) {
              final daysLeft = budget.dueDate.difference(DateTime.now()).inDays;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.receipt_outlined,
                        color: AppColors.secondary,
                        size: 20,
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
                              ? '₱${NumberFormat('#,##0').format(budget.amount)}'
                              : 'Free',
                          style: AppTextStyles.cardTitle.copyWith(
                            color: context.textPrimary,
                          ),
                        ),
                        if (daysLeft >= 0)
                          Text(
                            '$daysLeft days',
                            style: TextStyle(
                              fontSize: 10,
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
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaydayCard(List<Wallet> wallets) {
    final now = DateTime.now();
    final recurring = wallets.where(
      (w) => w.isRecurring && w.payDays.isNotEmpty,
    );
    if (recurring.isNotEmpty) {
      final salary = recurring.first;
      final nextPayday = DashboardHelper.getNextPayday(salary.payDays, now);
      final daysUntil = nextPayday.difference(now).inDays;
      double salaryAmount = salary.balance;
      final salaryLogs = salary.logs.where(
        (l) => l.description.toLowerCase().contains('salary'),
      );
      if (salaryLogs.isNotEmpty) salaryAmount = salaryLogs.first.amount;
      return PaydayCard(
        daysUntilPayday: daysUntil < 0 ? 0 : daysUntil,
        amount: salaryAmount / 2,
        paydayDate: nextPayday,
      );
    }

    final upcoming = wallets.where(
      (w) => w.status == 'Upcoming' && w.expectedPayoutDate != null,
    );
    if (upcoming.isEmpty) return const SizedBox.shrink();
    final next = upcoming.first;
    final daysUntil = next.expectedPayoutDate!.difference(now).inDays;
    return PaydayCard(
      daysUntilPayday: daysUntil < 0 ? 0 : daysUntil,
      amount: next.balance,
      paydayDate: next.expectedPayoutDate!,
    );
  }

  Widget _buildUpcomingTransactions(
    List<Wallet> wallets,
    List<Budget> budgets,
    List<Loan> loans,
    List<Credit> credits,
  ) {
    final income = DashboardHelper.buildIncomeTransactions(wallets);
    final expenses = DashboardHelper.buildExpenseTransactions(
      budgets,
      loans,
      credits,
    );
    return TransactionList(transactions: [...income, ...expenses]);
  }

  void _showAddExpense() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddExpenseDialog(),
    ).then((_) => _refreshData());
  }

  void _refreshData() {
    ref.read(walletsProvider.notifier).load();
    ref.read(budgetsProvider.notifier).load();
    ref.read(creditsProvider.notifier).load();
    ref.read(loansProvider.notifier).load();
  }
}
