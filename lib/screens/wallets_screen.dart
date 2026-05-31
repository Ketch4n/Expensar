import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/add_wallet_dialog.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  List<Wallet> _wallets = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final wallets = await DatabaseService.getWallets();
    if (!mounted) return;
    setState(() => _wallets = wallets);
  }

  @override
  Widget build(BuildContext context) {
    final totalBalance = _wallets.fold<double>(0, (sum, w) => sum + w.balance);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(child: AppHeader(title: 'Wallets')),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: _showAddWalletDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
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
                    const SizedBox(height: 8),
                    Text(
                      '₱${NumberFormat('#,##0.00').format(totalBalance)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_wallets.length} accounts',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 100,
                ),
                itemCount: _wallets.length,
                itemBuilder: (context, index) =>
                    _buildWalletCard(_wallets[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(Wallet wallet) {
    final (icon, iconColor) = switch (wallet.type) {
      'Debit' => (Icons.credit_card, AppColors.secondary),
      'Credit' => (Icons.credit_score, const Color(0xFFE91E63)),
      'Loans' => (Icons.handshake, AppColors.warning),
      'Assets' => (Icons.account_balance, AppColors.primary),
      'Stocks' => (Icons.show_chart, const Color(0xFF9C27B0)),
      'Crypto' => (Icons.currency_bitcoin, const Color(0xFFF57C00)),
      _ => (Icons.wallet, Colors.grey),
    };

    return GestureDetector(
      onTap: () => _showWalletDetails(wallet),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wallet.name, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        wallet.type,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      if (wallet.status != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            wallet.status!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₱${NumberFormat('#,##0.00').format(wallet.balance)}',
                  style: AppTextStyles.amountMedium,
                ),
                if (wallet.expectedPayoutDate != null)
                  Text(
                    DateFormat('MMM d').format(wallet.expectedPayoutDate!),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWalletDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddWalletDialog(),
    ).then((_) => _loadData());
  }

  void _showWalletDetails(Wallet wallet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(wallet.name, style: AppTextStyles.heading),
                  const Spacer(),
                  Text(
                    '₱${NumberFormat('#,##0.00').format(wallet.balance)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: wallet.logs.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: wallet.logs.length,
                      itemBuilder: (context, index) {
                        final log = wallet.logs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormat(
                                        'MMM d, h:mm a',
                                      ).format(log.date),
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
                                    '₱${NumberFormat('#,##0.00').format(log.amount)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (log.serviceCharge != null)
                                    Text(
                                      'Fee: ₱${log.serviceCharge!.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.red[400],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
