import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../models/account_group.dart';
import '../providers/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/add_wallet_dialog.dart';
import 'wallet_detail_screen.dart';
import 'account_groups_screen.dart';

enum _FilterTab { all, assets, liabilities }

class WalletsScreen extends ConsumerStatefulWidget {
  const WalletsScreen({super.key});

  @override
  ConsumerState<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends ConsumerState<WalletsScreen> {
  _FilterTab _activeTab = _FilterTab.all;

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    final groups = ref.watch(accountGroupsProvider);

    final filtered = switch (_activeTab) {
      _FilterTab.all => wallets,
      _FilterTab.assets => wallets.where((w) => w.isAsset).toList(),
      _FilterTab.liabilities => wallets.where((w) => w.isLiability).toList(),
    };

    final netWorth = _calculateNetWorth(wallets);

    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNetWorthCard(context, netWorth, wallets.length),
                    const SizedBox(height: 16),
                    _buildFilterTabs(context),
                    const SizedBox(height: 16),
                    if (filtered.isEmpty)
                      _buildEmptyState(context)
                    else
                      _buildGroupedList(context, filtered, groups),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateNetWorth(List<Wallet> wallets) {
    double net = 0;
    for (final w in wallets) {
      if (!w.includeInNetBalance) continue;
      if (w.isLiability) {
        net -= w.balance.abs();
      } else {
        net += w.balance;
      }
    }
    return net;
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: AppHeader(title: 'Accounts')),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccountGroupsScreen(),
                  ),
                ).then((_) {
                  ref.read(accountGroupsProvider.notifier).load();
                  ref.read(walletsProvider.notifier).load();
                }),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.folder_outlined,
                color: context.subtitleColor,
                size: 20,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () => _showAddWalletDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: context.isDark
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: context.isDark
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 1,
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: context.isDark
                        ? AppColors.primaryLighter
                        : Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Add Account',
                    style: TextStyle(
                      color: context.isDark
                          ? AppColors.primaryLighter
                          : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetWorthCard(
    BuildContext context,
    double netWorth,
    int accountCount,
  ) {
    final isNegative = netWorth < 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: context.isDark
              ? null
              : const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: context.isDark
              ? AppColors.primary.withValues(alpha: 0.1)
              : null,
          borderRadius: BorderRadius.circular(20),
          border: context.isDark
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
          boxShadow: context.isDark
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NET WORTH',
              style: TextStyle(
                fontSize: 11,
                color: context.isDark
                    ? AppColors.primary.withValues(alpha: 0.7)
                    : Colors.white70,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${isNegative ? '-' : ''}₱${NumberFormat('#,##0.00').format(netWorth.abs())}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: context.isDark
                    ? (isNegative ? AppColors.error : AppColors.primaryLighter)
                    : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Assets minus liabilities',
              style: TextStyle(
                fontSize: 13,
                color: context.isDark
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _filterChip(context, 'All', _FilterTab.all),
          const SizedBox(width: 8),
          _filterChip(context, 'Assets', _FilterTab.assets),
          const SizedBox(width: 8),
          _filterChip(context, 'Liabilities', _FilterTab.liabilities),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, _FilterTab tab) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : (context.isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : context.subtitleColor,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: context.subtitleColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No accounts yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your wallets, credit cards, and loans\nto track your finances.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: context.subtitleColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedList(
    BuildContext context,
    List<Wallet> wallets,
    List<AccountGroup> groups,
  ) {
    // Group wallets by their group (or "Ungrouped")
    final Map<String, List<Wallet>> grouped = {};
    final Map<String, double> groupTotals = {};

    for (final wallet in wallets) {
      final groupName = wallet.groupId != null
          ? groups
                    .where((g) => g.id == wallet.groupId)
                    .map((g) => g.name)
                    .firstOrNull ??
                'Other'
          : wallet.type; // Default grouping by type
      grouped.putIfAbsent(groupName, () => []).add(wallet);
    }

    // Calculate group totals
    for (final entry in grouped.entries) {
      double total = 0;
      for (final w in entry.value) {
        if (w.isLiability) {
          total -= w.balance.abs();
        } else {
          total += w.balance;
        }
      }
      groupTotals[entry.key] = total;
    }

    return Column(
      children: grouped.entries.map((entry) {
        return _buildGroupSection(
          context,
          entry.key,
          entry.value,
          groupTotals[entry.key] ?? 0,
        );
      }).toList(),
    );
  }

  Widget _buildGroupSection(
    BuildContext context,
    String groupName,
    List<Wallet> wallets,
    double total,
  ) {
    final isNegative = total < 0;
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.expand_more, size: 20, color: context.subtitleColor),
              const SizedBox(width: 4),
              Text(
                groupName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${isNegative ? '-' : ''}₱${NumberFormat('#,##0.00').format(total.abs())}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isNegative ? AppColors.error : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...wallets.map((wallet) => _buildWalletCard(context, wallet)),
        ],
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, Wallet wallet) {
    final (icon, iconColor) = _getWalletIcon(wallet.type);
    final subtitle = _getWalletSubtitle(wallet);

    return GestureDetector(
      onTap: () => _openWalletDetail(context, wallet),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppDecorations.cardShadow(context)],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getDisplayLabel(wallet),
                  style: TextStyle(
                    fontSize: 10,
                    color: context.subtitleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₱${NumberFormat('#,##0.00').format(wallet.balance)}',
                  style: AppTextStyles.amountMedium.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                if (wallet.type == 'Loans' && wallet.paymentAmount != null)
                  Text(
                    '₱${NumberFormat('#,##0.00').format(wallet.paymentAmount!)} per payment',
                    style: TextStyle(
                      fontSize: 10,
                      color: context.subtitleColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.more_horiz, size: 18, color: context.subtitleColor),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _getWalletIcon(String type) {
    return switch (type) {
      'Debit' => (Icons.credit_card, AppColors.secondary),
      'Credit' => (Icons.credit_score, const Color(0xFFE91E63)),
      'Loans' => (Icons.handshake, AppColors.warning),
      'Assets' => (Icons.account_balance, AppColors.primary),
      'Stocks' => (Icons.show_chart, const Color(0xFF9C27B0)),
      'Crypto' => (Icons.currency_bitcoin, const Color(0xFFF57C00)),
      _ => (Icons.wallet, Colors.grey),
    };
  }

  String _getWalletSubtitle(Wallet wallet) {
    final parts = <String>[wallet.type, wallet.currency];
    if (wallet.type == 'Credit' && wallet.dueDay != null) {
      parts.add('due day ${wallet.dueDay}');
    }
    if (wallet.type == 'Loans' && wallet.nextDueDate != null) {
      parts.add('next ${DateFormat('MMM d').format(wallet.nextDueDate!)}');
    }
    return parts.join(' • ');
  }

  String _getDisplayLabel(Wallet wallet) {
    return switch (wallet.type) {
      'Loans' => 'AMOUNT OWED',
      'Credit' => 'USED CREDIT',
      _ => 'BALANCE',
    };
  }

  void _openWalletDetail(BuildContext context, Wallet wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletDetailScreen(walletId: wallet.id!),
      ),
    ).then((_) {
      ref.read(walletsProvider.notifier).load();
      ref.read(accountGroupsProvider.notifier).load();
    });
  }

  void _showAddWalletDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddWalletDialog(),
    ).then((_) {
      ref.read(walletsProvider.notifier).load();
    });
  }
}
