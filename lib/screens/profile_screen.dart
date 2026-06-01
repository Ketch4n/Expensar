import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/wallet.dart';
import '../models/budget.dart';
import '../models/credit.dart';
import '../models/debt.dart';
import '../models/loan.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/data_providers.dart';
import '../services/database_service.dart';
import '../services/backup_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditingName = false;
  final _nameController = TextEditingController();

  static const _currencies = [
    _CurrencyOption(symbol: '₱', name: 'PHP'),
    _CurrencyOption(symbol: '\$', name: 'USD'),
    _CurrencyOption(symbol: '€', name: 'EUR'),
    _CurrencyOption(symbol: '£', name: 'GBP'),
    _CurrencyOption(symbol: '¥', name: 'JPY'),
    _CurrencyOption(symbol: '₩', name: 'KRW'),
    _CurrencyOption(symbol: '₹', name: 'INR'),
  ];

  static const _themes = [
    _ThemeOption(
      value: 'light',
      label: 'Light',
      icon: Icons.light_mode_rounded,
    ),
    _ThemeOption(value: 'dark', label: 'Dark', icon: Icons.dark_mode_rounded),
  ];

  @override
  void initState() {
    super.initState();
    // Sync the text controller with the current settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameController.text = ref.read(settingsProvider).userName;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final wallets = ref.watch(walletsProvider);
    final budgets = ref.watch(budgetsProvider);
    final credits = ref.watch(creditsProvider);
    final debts = ref.watch(debtsProvider);
    final loans = ref.watch(loansProvider);
    final themeMode = ref.watch(themeProvider);

    final userName = settings.userName;
    final currency = settings.currency;

    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: context.isDark
                ? AppColors.darkCardBackground
                : AppColors.primary,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: context.isDark ? AppColors.primaryLighter : Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: context.isDark
                      ? null
                      : const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: context.isDark
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : null,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.isDark
                                ? AppColors.primary.withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: context.isDark
                                  ? AppColors.primaryLighter
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.isDark
                              ? AppColors.darkTextPrimary
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Member since ${DateFormat('MMM yyyy').format(DateTime.now())}',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.isDark
                              ? AppColors.primary.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildNameSection(userName),
                  const SizedBox(height: 20),
                  _buildQuickStats(wallets, budgets, credits, debts, loans),
                  const SizedBox(height: 20),
                  _buildSettingsSection(currency, themeMode),
                  const SizedBox(height: 24),
                  _buildMenuSection('Data Management', [
                    _MenuItem(
                      icon: Icons.upload_rounded,
                      title: 'Export Backup',
                      subtitle: 'Save data as JSON',
                      color: AppColors.secondary,
                      onTap: _exportData,
                    ),
                    _MenuItem(
                      icon: Icons.download_rounded,
                      title: 'Import Backup',
                      subtitle: 'Restore from file',
                      color: AppColors.primary,
                      onTap: _importData,
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildMenuSection('Danger Zone', [
                    _MenuItem(
                      icon: Icons.delete_forever_rounded,
                      title: 'Reset All Data',
                      subtitle: 'Permanently delete everything',
                      color: AppColors.error,
                      onTap: _showResetDialog,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildAppInfo(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection(String userName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(context),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _isEditingName
                ? TextField(
                    controller: _nameController,
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _saveName(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Display Name',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.subtitleColor,
                        ),
                      ),
                    ],
                  ),
          ),
          GestureDetector(
            onTap: _isEditingName
                ? _saveName
                : () => setState(() => _isEditingName = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _isEditingName
                    ? AppColors.primary
                    : context.chipBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _isEditingName ? 'Save' : 'Edit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isEditingName ? Colors.white : context.subtitleColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await ref.read(settingsProvider.notifier).setUserName(name);
    }
    setState(() => _isEditingName = false);
  }

  Widget _buildQuickStats(
    List<Wallet> wallets,
    List<Budget> budgets,
    List<Credit> credits,
    List<Debt> debts,
    List<Loan> loans,
  ) {
    final totalBalance = wallets.fold<double>(0, (sum, w) => sum + w.balance);
    final totalDebt =
        debts.fold<double>(0, (sum, d) => sum + d.remainingBalance) +
        loans.fold<double>(0, (sum, l) => sum + l.balance) +
        credits.fold<double>(0, (sum, c) => sum + c.outstandingBalance);
    final upcomingBills = budgets
        .where((b) => b.status == 'Upcoming')
        .fold<double>(0, (sum, b) => sum + b.amount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Financial Overview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _statTile(
                  'Net Worth',
                  '₱${NumberFormat('#,##0').format(totalBalance)}',
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statTile(
                  'Total Debt',
                  '₱${NumberFormat('#,##0').format(totalDebt)}',
                  AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statTile(
                  'Upcoming Bills',
                  '₱${NumberFormat('#,##0').format(upcomingBills)}',
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statTile(
                  'Accounts',
                  '${wallets.length} wallets',
                  AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.subtitleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String currency, ThemeMode themeMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tune_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildCurrencyRow(currency),
          const SizedBox(height: 16),
          _buildThemeRow(themeMode),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow(String currency) {
    final selected = _currencies.firstWhere(
      (c) => c.symbol == currency,
      orElse: () => _currencies.first,
    );

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.attach_money_rounded,
            color: AppColors.warning,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Currency',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              Text(
                '${selected.symbol} ${selected.name}',
                style: TextStyle(fontSize: 11, color: context.subtitleColor),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _showCurrencyPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.chipBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selected.symbol,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.unfold_more_rounded,
                  size: 16,
                  color: context.subtitleColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCurrencyPicker() {
    final currency = ref.read(settingsProvider).currency;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: this.context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Currency',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: this.context.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
                children: _currencies.map((c) {
                  final isSelected = currency == c.symbol;
                  return GestureDetector(
                    onTap: () {
                      ref.read(settingsProvider.notifier).setCurrency(c.symbol);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : this.context.chipBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : this.context.dividerColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            c.symbol,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.primary
                                  : this.context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : this.context.subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeRow(ThemeMode themeMode) {
    final isDark = themeMode == ThemeMode.dark;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.palette_rounded,
            color: AppColors.accent,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              Text(
                isDark ? 'Dark Mode' : 'Light Mode',
                style: TextStyle(fontSize: 11, color: context.subtitleColor),
              ),
            ],
          ),
        ),
        // Dark / Light toggle chips
        Row(
          mainAxisSize: MainAxisSize.min,
          children: _themes.map((theme) {
            final isSelected = (theme.value == 'dark') == isDark;
            return Padding(
              padding: const EdgeInsets.only(left: 6),
              child: GestureDetector(
                onTap: () {
                  ref.read(themeProvider.notifier).setThemeMode(theme.value);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : context.chipBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        theme.icon,
                        size: 16,
                        color: isSelected
                            ? AppColors.primary
                            : context.subtitleColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        theme.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : context.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Container(
      decoration: AppDecorations.card(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(title.toUpperCase(), style: AppTextStyles.sectionLabel),
          ),
          ...items.asMap().entries.map((entry) {
            final item = entry.value;
            final isLast = entry.key == items.length - 1;
            return Column(
              children: [
                InkWell(
                  onTap: item.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(item.icon, color: item.color, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: item.color == AppColors.error
                                      ? AppColors.error
                                      : context.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: context.subtitleColor,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, indent: 74, color: context.dividerColor),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.savings_rounded,
            color: AppColors.primary,
            size: 26,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Expensar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version 1.0.0',
          style: TextStyle(fontSize: 12, color: context.subtitleColor),
        ),
        const SizedBox(height: 8),
        Text(
          'Your personal finance companion',
          style: TextStyle(fontSize: 13, color: context.subtitleColor),
        ),
      ],
    );
  }

  Future<void> _exportData() async {
    try {
      final filePath = await BackupService.exportData();
      if (!mounted) return;
      await Share.shareXFiles([XFile(filePath)], text: 'Expensar Backup');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _importData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return;
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Import Data?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'This will replace all existing data with the imported backup. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Import',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final importResult = await BackupService.importData(
      result.files.single.path!,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(importResult.message),
        backgroundColor: importResult.success
            ? AppColors.primary
            : AppColors.error,
      ),
    );

    if (importResult.success) {
      // Reload all providers
      ref.read(walletsProvider.notifier).load();
      ref.read(budgetsProvider.notifier).load();
      ref.read(creditsProvider.notifier).load();
      ref.read(debtsProvider.notifier).load();
      ref.read(loansProvider.notifier).load();
      ref.read(settingsProvider.notifier).reload();
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error, size: 24),
            SizedBox(width: 10),
            Text(
              'Reset All Data?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          'This will permanently delete all your wallets, budgets, loans, debts, and credits. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          FilledButton(
            onPressed: () async {
              await DatabaseService.clearAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been reset'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
              // Reload all providers
              ref.read(walletsProvider.notifier).load();
              ref.read(budgetsProvider.notifier).load();
              ref.read(creditsProvider.notifier).load();
              ref.read(debtsProvider.notifier).load();
              ref.read(loansProvider.notifier).load();
              ref.read(settingsProvider.notifier).reload();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }
}

class _CurrencyOption {
  final String symbol;
  final String name;

  const _CurrencyOption({required this.symbol, required this.name});
}

class _ThemeOption {
  final String value;
  final String label;
  final IconData icon;

  const _ThemeOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });
}
