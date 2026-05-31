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
  String _userName = 'User';
  bool _isEditingName = false;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final wallets = await DatabaseService.getWallets();
    final budgets = await DatabaseService.getBudgets();
    final credits = await DatabaseService.getCredits();
    final debts = await DatabaseService.getDebts();
    final loans = await DatabaseService.getLoans();
    final name = await DatabaseService.getSetting('userName');
    if (!mounted) return;
    setState(() {
      _wallets = wallets;
      _budgets = budgets;
      _credits = credits;
      _debts = debts;
      _loans = loans;
      _userName = name ?? 'User';
      _nameController.text = _userName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Collapsing header with profile info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _userName.isNotEmpty
                                ? _userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Member since ${DateFormat('MMM yyyy').format(DateTime.now())}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildNameSection(),
                  const SizedBox(height: 20),
                  _buildQuickStats(),
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

  Widget _buildNameSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
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
                        _userName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Display Name',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
                color: _isEditingName ? AppColors.primary : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _isEditingName ? 'Save' : 'Edit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isEditingName ? Colors.white : Colors.grey[600],
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
      await DatabaseService.setSetting('userName', name);
      setState(() {
        _userName = name;
        _isEditingName = false;
      });
    } else {
      setState(() => _isEditingName = false);
    }
  }

  Widget _buildQuickStats() {
    final totalBalance = _wallets.fold<double>(0, (sum, w) => sum + w.balance);
    final totalDebt =
        _debts.fold<double>(0, (sum, d) => sum + d.remainingBalance) +
        _loans.fold<double>(0, (sum, l) => sum + l.balance) +
        _credits.fold<double>(0, (sum, c) => sum + c.outstandingBalance);
    final upcomingBills = _budgets
        .where((b) => b.status == 'Upcoming')
        .fold<double>(0, (sum, b) => sum + b.amount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
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
              const Text(
                'Financial Overview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
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
                  '${_wallets.length} wallets',
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
              color: Colors.grey[500],
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

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Container(
      decoration: AppDecorations.card(),
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
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey[350],
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, indent: 74, color: Colors.grey[100]),
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
        const Text(
          'Expensar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version 1.0.0',
          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
        ),
        const SizedBox(height: 8),
        Text(
          'Your personal finance companion',
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
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

    if (importResult.success) _loadData();
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
              _loadData();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }
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
