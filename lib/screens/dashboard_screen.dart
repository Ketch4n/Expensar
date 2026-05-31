import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../models/budget.dart';
import '../models/credit.dart';
import '../models/loan.dart';
import '../services/database_service.dart';
import '../services/dashboard_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/greeting_card.dart';
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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Wallet> _wallets = [];
  List<Budget> _budgets = [];
  List<Credit> _credits = [];
  List<Loan> _loans = [];
  String _userName = 'Friend';

  int _currentIndex = 0;
  late final PageController _pageController;

  // Scroll-hide state
  bool _isNavVisible = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final wallets = await DatabaseService.getWallets();
    final budgets = await DatabaseService.getBudgets();
    final credits = await DatabaseService.getCredits();
    final loans = await DatabaseService.getLoans();
    final name = await DatabaseService.getSetting('userName');
    if (!mounted) return;
    setState(() {
      _wallets = wallets;
      _budgets = budgets;
      _credits = credits;
      _loans = loans;
      _userName = name ?? 'Friend';
    });
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;

      // Scroll down → hide nav
      if (delta > 2 && _isNavVisible) {
        setState(() => _isNavVisible = false);
      }
      // Scroll up → show nav
      else if (delta < -2 && !_isNavVisible) {
        setState(() => _isNavVisible = true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: [
            _buildHomePage(),
            const StatsScreen(),
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
              // Floating nav bar
              Expanded(
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _navItem(Icons.home_rounded, 'Home', 0),
                      _navItem(Icons.bar_chart_rounded, 'Stats', 1),
                      _navItem(Icons.wallet_rounded, 'Wallet', 2),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // FAB add expense
              GestureDetector(
                onTap: _showAddExpense,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
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
                color: isActive ? AppColors.primary : Colors.grey[400],
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppColors.primary : Colors.grey[400],
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    final totalBalance = _wallets.fold<double>(0, (sum, w) => sum + w.balance);
    final dailySpending = DashboardHelper.calculateDailySpending(_wallets);
    final todayTotal = dailySpending.last;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header / App Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TimeOfDay.now().format(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                      color: Colors.grey[600],
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {},
                      color: Colors.grey[600],
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                        _loadData();
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
                  GreetingCard(userName: _userName),
                  const SizedBox(height: 20),
                  _buildQuickActions(),
                  const SizedBox(height: 20),
                  _buildWalletSummary(totalBalance),
                  const SizedBox(height: 20),
                  SpendingChart(
                    data: dailySpending.every((d) => d == 0)
                        ? [150, 280, 180, 320, 220, 180, 469]
                        : dailySpending,
                    todayAmount: todayTotal,
                  ),
                  const SizedBox(height: 20),
                  _buildUpcomingBills(),
                  const SizedBox(height: 20),
                  _buildPaydayCard(),
                  const SizedBox(height: 20),
                  _buildUpcomingTransactions(),
                  // Extra padding so content isn't hidden behind floating nav
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
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
        _loadData();
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
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSummary(double totalBalance) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WalletsScreen()),
        );
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
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
                  const Text(
                    'TOTAL BALANCE',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱${NumberFormat('#,##0.00').format(totalBalance)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingBills() {
    final sorted = List<Budget>.from(_budgets)
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (sorted.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BudgetsScreen()),
        );
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.card(),
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
                    color: Colors.grey[500],
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
                          Text(budget.name, style: AppTextStyles.cardTitle),
                          Text(
                            DateFormat('MMM d').format(budget.dueDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
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
                          style: AppTextStyles.cardTitle,
                        ),
                        if (daysLeft >= 0)
                          Text(
                            '$daysLeft days',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: daysLeft <= 3
                                  ? AppColors.error
                                  : Colors.grey[500],
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

  Widget _buildPaydayCard() {
    final now = DateTime.now();
    final recurring = _wallets.where(
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

    final upcoming = _wallets.where(
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

  Widget _buildUpcomingTransactions() {
    final income = DashboardHelper.buildIncomeTransactions(_wallets);
    final expenses = DashboardHelper.buildExpenseTransactions(
      _budgets,
      _loans,
      _credits,
    );
    return TransactionList(transactions: [...income, ...expenses]);
  }

  void _showAddExpense() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddExpenseDialog(),
    ).then((_) => _loadData());
  }
}
