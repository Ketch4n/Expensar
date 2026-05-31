import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/wallet.dart';
import '../models/budget.dart';
import '../models/credit.dart';
import '../models/debt.dart';
import '../models/loan.dart';
import '../services/database_service.dart';
import '../services/backup_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    final totalBalance = _wallets.fold<double>(0, (sum, w) => sum + w.balance);
    final totalBills = _budgets
        .where((b) => b.status == 'Upcoming')
        .fold<double>(0, (sum, b) => sum + b.amount);
    final totalDebt =
        _debts.fold<double>(0, (sum, d) => sum + d.remainingBalance) +
        _loans.fold<double>(0, (sum, l) => sum + l.balance) +
        _credits.fold<double>(0, (sum, c) => sum + c.outstandingBalance);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Profile'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 20),
                    _buildFinancialSummary(totalBalance, totalBills, totalDebt),
                    const SizedBox(height: 20),
                    _buildSettingsSection(),
                    const SizedBox(height: 20),
                    _buildAboutSection(),
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

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expensar User',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Personal Finance Manager',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'v1.0',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(
    double totalBalance,
    double totalBills,
    double totalDebt,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FINANCIAL SNAPSHOT', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 16),
          _summaryRow(
            Icons.account_balance_wallet,
            'Net Worth',
            '₱${NumberFormat('#,##0').format(totalBalance)}',
            AppColors.primary,
          ),
          const SizedBox(height: 12),
          _summaryRow(
            Icons.receipt_outlined,
            'Upcoming Bills',
            '₱${NumberFormat('#,##0').format(totalBills)}',
            AppColors.secondary,
          ),
          const SizedBox(height: 12),
          _summaryRow(
            Icons.trending_down,
            'Total Debt',
            '₱${NumberFormat('#,##0').format(totalDebt)}',
            AppColors.error,
          ),
          const SizedBox(height: 12),
          _summaryRow(
            Icons.wallet,
            'Wallets',
            '${_wallets.length} active',
            AppColors.warning,
          ),
          const SizedBox(height: 12),
          _summaryRow(
            Icons.credit_card,
            'Credit Cards',
            '${_credits.length} cards',
            AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SETTINGS', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 16),
          _settingsTile(
            Icons.notifications_outlined,
            'Notifications',
            'Bill reminders & alerts',
          ),
          _settingsTile(
            Icons.palette_outlined,
            'Appearance',
            'Theme & display settings',
          ),
          _settingsTile(Icons.lock_outline, 'Security', 'App lock & privacy'),
          _settingsTile(
            Icons.upload_outlined,
            'Export Data',
            'Save all data as JSON file',
            onTap: _exportData,
          ),
          _settingsTile(
            Icons.download_outlined,
            'Import Data',
            'Restore from a JSON backup',
            onTap: _importData,
          ),
          _settingsTile(
            Icons.delete_outline,
            'Reset Data',
            'Clear all app data',
            color: AppColors.error,
            onTap: _showResetDialog,
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(
    IconData icon,
    String title,
    String subtitle, {
    Color color = AppColors.textPrimary,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ABOUT', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.savings_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expensar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your personal finance companion. Track wallets, budgets, loans, and debts all in one place.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      final filePath = await BackupService.exportData();
      if (!mounted) return;

      // Share the file
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

    // Confirm before overwriting
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

    if (importResult.success) _loadData();
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reset All Data?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'This will permanently delete all your wallets, budgets, loans, debts, and credits. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
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
              _loadData();
            },
            child: const Text(
              'Reset',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
