import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../providers/data_providers.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/add_wallet_dialog.dart';

class WalletDetailScreen extends ConsumerStatefulWidget {
  final int walletId;

  const WalletDetailScreen({super.key, required this.walletId});

  @override
  ConsumerState<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends ConsumerState<WalletDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    final wallet = wallets.where((w) => w.id == widget.walletId).firstOrNull;

    if (wallet == null) {
      return Scaffold(
        backgroundColor: context.scaffoldBackground,
        body: const Center(child: Text('Wallet not found')),
      );
    }

    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, wallet),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    _buildHeroCard(context, wallet),
                    const SizedBox(height: 20),
                    _buildTypeSpecificContent(context, wallet),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, Wallet wallet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.isDark ? Colors.grey[800] : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: context.textPrimary,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _confirmDelete(context, wallet),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _editWallet(context, wallet),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.isDark ? Colors.grey[800] : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_outlined,
                color: context.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, Wallet wallet) {
    final (gradient, labelText) = _getHeroStyle(wallet);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTypeIcon(wallet.type),
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  wallet.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    wallet.type,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              labelText,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₱${NumberFormat('#,##0.00').format(wallet.balance)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (LinearGradient, String) _getHeroStyle(Wallet wallet) {
    return switch (wallet.type) {
      'Debit' => (
        const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'BALANCE',
      ),
      'Credit' => (
        const LinearGradient(
          colors: [Color(0xFFE65100), Color(0xFFF57C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'USED CREDIT',
      ),
      'Loans' => (
        const LinearGradient(
          colors: [Color(0xFFC62828), Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'AMOUNT OWED',
      ),
      'Assets' => (
        const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'BALANCE',
      ),
      'Stocks' => (
        const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'BALANCE',
      ),
      'Crypto' => (
        const LinearGradient(
          colors: [Color(0xFFE65100), Color(0xFFF57C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'BALANCE',
      ),
      _ => (
        const LinearGradient(
          colors: [Color(0xFF455A64), Color(0xFF78909C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'BALANCE',
      ),
    };
  }

  IconData _getTypeIcon(String type) {
    return switch (type) {
      'Debit' => Icons.credit_card,
      'Credit' => Icons.credit_score,
      'Loans' => Icons.handshake,
      'Assets' => Icons.account_balance,
      'Stocks' => Icons.show_chart,
      'Crypto' => Icons.currency_bitcoin,
      _ => Icons.wallet,
    };
  }

  Widget _buildTypeSpecificContent(BuildContext context, Wallet wallet) {
    return switch (wallet.type) {
      'Debit' ||
      'Assets' ||
      'Stocks' ||
      'Crypto' => _buildDebitContent(context, wallet),
      'Credit' => _buildCreditContent(context, wallet),
      'Loans' => _buildLoanContent(context, wallet),
      _ => _buildDebitContent(context, wallet),
    };
  }

  // ─── DEBIT / ASSET CONTENT ───────────────────────────────────────

  Widget _buildDebitContent(BuildContext context, Wallet wallet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Balance info
          _buildInfoCard(
            context,
            children: [
              Row(
                children: [
                  _buildInfoColumn(
                    'NET BALANCE',
                    '₱${NumberFormat('#,##0.00').format(wallet.balance)}',
                  ),
                  const SizedBox(width: 24),
                  _buildInfoColumn(
                    'SPENDABLE',
                    '₱${NumberFormat('#,##0.00').format(wallet.balance)}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      Icons.swap_horiz,
                      'Transfer',
                      () => _showTransferDialog(context, wallet),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      Icons.edit_outlined,
                      'Adjustment',
                      () => _showAdjustmentDialog(context, wallet),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quick actions
          _buildInfoCard(
            context,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      Icons.remove_circle_outline,
                      'Add expense',
                      () => _showAddLogDialog(context, wallet, isExpense: true),
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      Icons.add_circle_outline,
                      'Add income',
                      () =>
                          _showAddLogDialog(context, wallet, isExpense: false),
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTransactionHistory(context, wallet),
        ],
      ),
    );
  }

  // ─── CREDIT CONTENT ──────────────────────────────────────────────

  Widget _buildCreditContent(BuildContext context, Wallet wallet) {
    final usedCredit = wallet.usedCredit;
    final usagePercent = wallet.creditUsagePercent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Credit limit info
          _buildInfoCard(
            context,
            children: [
              Row(
                children: [
                  _buildInfoColumn(
                    'TOTAL LIMIT',
                    '₱${NumberFormat('#,##0.00').format(wallet.creditLimit ?? 0)}',
                  ),
                  const SizedBox(width: 24),
                  _buildInfoColumn(
                    'AVAILABLE CREDIT',
                    '₱${NumberFormat('#,##0.00').format((wallet.creditLimit ?? 0) - usedCredit)}',
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: usagePercent / 100,
                  backgroundColor: context.isDark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  color: usagePercent > 80
                      ? AppColors.error
                      : AppColors.primary,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ve used ${usagePercent.toStringAsFixed(0)}% of your credit limit.',
                style: TextStyle(fontSize: 12, color: context.subtitleColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Due info
          _buildInfoCard(
            context,
            children: [
              Row(
                children: [
                  _buildInfoColumn(
                    'AMOUNT DUE',
                    '₱${NumberFormat('#,##0.00').format(usedCredit)}',
                  ),
                  if (wallet.dueDay != null) ...[
                    const SizedBox(width: 20),
                    _buildInfoColumn('DUE DAY', '${wallet.dueDay}'),
                  ],
                  if (wallet.statementDay != null) ...[
                    const SizedBox(width: 20),
                    _buildInfoColumn('STATEMENT', '${wallet.statementDay}'),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                context,
                Icons.swap_horiz,
                'Pay card',
                () => _showPayCardDialog(context, wallet),
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                context,
                Icons.edit_outlined,
                'Adjustment',
                () => _showAdjustmentDialog(context, wallet),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTransactionHistory(context, wallet),
        ],
      ),
    );
  }

  // ─── LOAN CONTENT ────────────────────────────────────────────────

  Widget _buildLoanContent(BuildContext context, Wallet wallet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Amount owed + next due
          _buildInfoCard(
            context,
            children: [
              Row(
                children: [
                  _buildInfoColumn(
                    'AMOUNT OWED',
                    '₱${NumberFormat('#,##0.00').format(wallet.balance)}',
                  ),
                  const SizedBox(width: 24),
                  if (wallet.nextDueDate != null)
                    _buildInfoColumn(
                      'NEXT DUE',
                      DateFormat('MMMM d, yyyy').format(wallet.nextDueDate!),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                context,
                Icons.edit_outlined,
                'Adjust owed',
                () => _showAdjustmentDialog(context, wallet),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Loan schedule
          _buildInfoCard(
            context,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LOAN SCHEDULE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.grey,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAddPaymentDialog(context, wallet),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Add payment',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (wallet.paymentAmount != null) ...[
                Row(
                  children: [
                    Text(
                      '₱${NumberFormat('#,##0.00').format(wallet.paymentAmount!)} per payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${wallet.loanProgressPercent.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.subtitleColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (wallet.totalPayments != null) ...[
                Row(
                  children: [
                    _buildLoanChip(
                      context,
                      Icons.check_circle,
                      '${wallet.completedPayments ?? 0}/${wallet.totalPayments} logged',
                      AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    _buildLoanChip(
                      context,
                      Icons.hourglass_bottom,
                      '${wallet.remainingPayments} left',
                      AppColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: wallet.loanProgressPercent / 100,
                    backgroundColor: context.isDark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    color: AppColors.primary,
                    minHeight: 6,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (wallet.loanStartDate != null)
                _buildDateRow(
                  context,
                  Icons.play_arrow,
                  'STARTED',
                  DateFormat('MMMM d, yyyy').format(wallet.loanStartDate!),
                ),
              if (wallet.loanEndDate != null) ...[
                const SizedBox(height: 8),
                _buildDateRow(
                  context,
                  Icons.flag,
                  'ENDS',
                  DateFormat('MMMM d, yyyy').format(wallet.loanEndDate!),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          _buildTransactionHistory(context, wallet),
        ],
      ),
    );
  }

  // ─── SHARED WIDGETS ──────────────────────────────────────────────

  Widget _buildInfoCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppDecorations.cardShadow(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    final btnColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: btnColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: btnColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: btnColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: btnColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: context.subtitleColor,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── TRANSACTION HISTORY ─────────────────────────────────────────

  Widget _buildTransactionHistory(BuildContext context, Wallet wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 18, color: context.textPrimary),
            const SizedBox(width: 8),
            Text(
              'Transaction history',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _getHistorySubtitle(wallet.type),
          style: TextStyle(fontSize: 13, color: context.subtitleColor),
        ),
        const SizedBox(height: 16),
        if (wallet.logs.isEmpty)
          _buildEmptyTransactions(context)
        else
          _buildTransactionList(context, wallet.logs),
      ],
    );
  }

  String _getHistorySubtitle(String type) {
    return switch (type) {
      'Loans' =>
        'Logged loan payments and related balance changes appear here.',
      'Credit' =>
        'Card spending, payments, and balance adjustments are grouped by credit card cycle.',
      _ =>
        'Expenses, income, balance adjustments, card payments, and transfers under this account appear here.',
    };
  }

  Widget _buildEmptyTransactions(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: context.subtitleColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Expenses, income, balance adjustments,\nand transfers logged to this account\nwill show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: context.subtitleColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, List<WalletLog> logs) {
    // Group by date
    final Map<String, List<WalletLog>> grouped = {};
    for (final log in logs) {
      final key = DateFormat('EEE, MMM d').format(log.date).toUpperCase();
      grouped.putIfAbsent(key, () => []).add(log);
    }

    return Column(
      children: grouped.entries.map((entry) {
        final dayTotal = entry.value.fold<double>(
          0,
          (sum, l) => sum - l.amount - (l.serviceCharge ?? 0),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.subtitleColor,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${dayTotal < 0 ? '-' : '+'}₱${NumberFormat('#,##0.00').format(dayTotal.abs())}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: dayTotal < 0 ? AppColors.error : AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...entry.value.map((log) => _buildLogItem(context, log)),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLogItem(BuildContext context, WalletLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppDecorations.cardShadow(context)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('h:mm a').format(log.date),
                  style: TextStyle(fontSize: 12, color: context.subtitleColor),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-₱${NumberFormat('#,##0.00').format(log.amount)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              if (log.serviceCharge != null)
                Text(
                  'Fee: ₱${log.serviceCharge!.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 11, color: Colors.red[400]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── DIALOGS ─────────────────────────────────────────────────────

  void _confirmDelete(BuildContext context, Wallet wallet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete ${wallet.name}?',
          style: TextStyle(color: context.textPrimary),
        ),
        content: Text(
          'This will permanently delete this account and all its transaction history.',
          style: TextStyle(color: context.subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.subtitleColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseService.deleteWallet(wallet.id!);
              if (!mounted) return;
              Navigator.pop(ctx);
              Navigator.pop(context);
              ref.read(walletsProvider.notifier).load();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _editWallet(BuildContext context, Wallet wallet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddWalletDialog(editWallet: wallet),
    ).then((_) => ref.read(walletsProvider.notifier).load());
  }

  void _showTransferDialog(BuildContext context, Wallet wallet) {
    final amountController = TextEditingController();
    final wallets = ref
        .read(walletsProvider)
        .where((w) => w.id != wallet.id && w.isAsset)
        .toList();
    Wallet? targetWallet;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.isDark ? Colors.grey[600] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Transfer from ${wallet.name}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<Wallet>(
                decoration: InputDecoration(
                  labelText: 'To account',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: context.scaffoldBackground,
                ),
                items: wallets
                    .map((w) => DropdownMenuItem(value: w, child: Text(w.name)))
                    .toList(),
                onChanged: (w) => setSheetState(() => targetWallet = w),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount (₱)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: context.scaffoldBackground,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0 || targetWallet == null) return;
                    await _executeTransfer(wallet, targetWallet!, amount);
                    if (!mounted) return;
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Transfer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _executeTransfer(Wallet from, Wallet to, double amount) async {
    final now = DateTime.now();
    // Deduct from source
    final newFromBalance = from.balance - amount;
    await DatabaseService.updateWallet(from.copyWith(balance: newFromBalance));
    await DatabaseService.insertWalletLog(
      WalletLog(
        walletId: from.id!,
        date: now,
        description: 'Transfer to ${to.name}',
        amount: amount,
        postBalance: newFromBalance,
      ),
    );
    // Add to target
    final newToBalance = to.balance + amount;
    await DatabaseService.updateWallet(to.copyWith(balance: newToBalance));
    await DatabaseService.insertWalletLog(
      WalletLog(
        walletId: to.id!,
        date: now,
        description: 'Transfer from ${from.name}',
        amount: amount,
        postBalance: newToBalance,
      ),
    );
    ref.read(walletsProvider.notifier).load();
  }

  void _showAdjustmentDialog(BuildContext context, Wallet wallet) {
    final amountController = TextEditingController(
      text: wallet.balance.toStringAsFixed(2),
    );
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Adjust balance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'New balance (₱)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: context.scaffoldBackground,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: context.scaffoldBackground,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final newBalance =
                      double.tryParse(amountController.text) ?? wallet.balance;
                  final diff = newBalance - wallet.balance;
                  await DatabaseService.updateWallet(
                    wallet.copyWith(balance: newBalance),
                  );
                  await DatabaseService.insertWalletLog(
                    WalletLog(
                      walletId: wallet.id!,
                      date: DateTime.now(),
                      description: noteController.text.isNotEmpty
                          ? noteController.text
                          : 'Balance adjustment',
                      amount: diff.abs(),
                      postBalance: newBalance,
                    ),
                  );
                  ref.read(walletsProvider.notifier).load();
                  if (!mounted) return;
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddLogDialog(
    BuildContext context,
    Wallet wallet, {
    required bool isExpense,
  }) {
    final amountController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isExpense ? 'Add expense' : 'Add income',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: context.scaffoldBackground,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Amount (₱)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: context.scaffoldBackground,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount <= 0 || descController.text.isEmpty) return;

                  final newBalance = isExpense
                      ? wallet.balance - amount
                      : wallet.balance + amount;
                  await DatabaseService.updateWallet(
                    wallet.copyWith(balance: newBalance),
                  );
                  await DatabaseService.insertWalletLog(
                    WalletLog(
                      walletId: wallet.id!,
                      date: DateTime.now(),
                      description: descController.text.trim(),
                      amount: amount,
                      postBalance: newBalance,
                    ),
                  );
                  ref.read(walletsProvider.notifier).load();
                  if (!mounted) return;
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isExpense
                      ? AppColors.error
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isExpense ? 'Add expense' : 'Add income',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context, Wallet wallet) {
    final amountController = TextEditingController(
      text: wallet.paymentAmount?.toStringAsFixed(2) ?? '',
    );
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Log payment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Payment amount (₱)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: context.scaffoldBackground,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: context.scaffoldBackground,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) return;

                  final newBalance = wallet.balance - amount;
                  final newCompleted = (wallet.completedPayments ?? 0) + 1;
                  await DatabaseService.updateWallet(
                    wallet.copyWith(
                      balance: newBalance,
                      completedPayments: newCompleted,
                    ),
                  );
                  await DatabaseService.insertWalletLog(
                    WalletLog(
                      walletId: wallet.id!,
                      date: DateTime.now(),
                      description: noteController.text.isNotEmpty
                          ? noteController.text
                          : 'Loan payment',
                      amount: amount,
                      postBalance: newBalance,
                    ),
                  );
                  ref.read(walletsProvider.notifier).load();
                  if (!mounted) return;
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log payment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPayCardDialog(BuildContext context, Wallet wallet) {
    final amountController = TextEditingController(
      text: wallet.usedCredit.toStringAsFixed(2),
    );
    final wallets = ref
        .read(walletsProvider)
        .where((w) => w.id != wallet.id && w.isAsset)
        .toList();
    Wallet? sourceWallet;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.isDark ? Colors.grey[600] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pay ${wallet.name}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<Wallet>(
                decoration: InputDecoration(
                  labelText: 'Pay from',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: context.scaffoldBackground,
                ),
                items: wallets
                    .map(
                      (w) => DropdownMenuItem(
                        value: w,
                        child: Text(
                          '${w.name} (₱${NumberFormat('#,##0.00').format(w.balance)})',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (w) => setSheetState(() => sourceWallet = w),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount (₱)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: context.scaffoldBackground,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0 || sourceWallet == null) return;

                    final now = DateTime.now();
                    // Deduct from source wallet
                    final newSourceBal = sourceWallet!.balance - amount;
                    await DatabaseService.updateWallet(
                      sourceWallet!.copyWith(balance: newSourceBal),
                    );
                    await DatabaseService.insertWalletLog(
                      WalletLog(
                        walletId: sourceWallet!.id!,
                        date: now,
                        description: 'Payment to ${wallet.name}',
                        amount: amount,
                        postBalance: newSourceBal,
                      ),
                    );
                    // Increase available credit
                    final newCreditBal = wallet.balance + amount;
                    await DatabaseService.updateWallet(
                      wallet.copyWith(balance: newCreditBal),
                    );
                    await DatabaseService.insertWalletLog(
                      WalletLog(
                        walletId: wallet.id!,
                        date: now,
                        description: 'Payment from ${sourceWallet!.name}',
                        amount: amount,
                        postBalance: newCreditBal,
                      ),
                    );
                    ref.read(walletsProvider.notifier).load();
                    if (!mounted) return;
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Pay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
