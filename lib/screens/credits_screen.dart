import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../providers/data_providers.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/payment_bottom_sheet.dart';

class CreditsScreen extends ConsumerWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletsProvider);
    final credits = wallets.where((w) => w.type == 'Credit').toList();

    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Credits',
              trailing: GestureDetector(
                onTap: () => _showAddCreditDialog(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
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
                        'Add',
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
            Expanded(
              child: credits.isEmpty
                  ? Center(
                      child: Text(
                        'No credit cards yet',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: credits.length,
                      itemBuilder: (context, index) =>
                          _buildCreditCard(context, credits[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCreditDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final limitController = TextEditingController();
    final balanceController = TextEditingController();
    final dueDayController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? Colors.grey[600]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Add Credit Card',
                  style: AppTextStyles.heading.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  context,
                  nameController,
                  'Card Name',
                  icon: Icons.credit_card,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  context,
                  limitController,
                  'Credit Limit',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  context,
                  balanceController,
                  'Current Balance (available)',
                  icon: Icons.account_balance_wallet,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  context,
                  dueDayController,
                  'Due Day (1-31)',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final limit = double.tryParse(
                        limitController.text.trim(),
                      );
                      final balance = double.tryParse(
                        balanceController.text.trim(),
                      );
                      final dueDay = int.tryParse(dueDayController.text.trim());

                      if (name.isEmpty || limit == null) return;

                      final wallet = Wallet(
                        name: name,
                        balance: balance ?? limit,
                        type: 'Credit',
                        creditLimit: limit,
                        dueDay: dueDay,
                        currency: 'PHP',
                      );

                      await DatabaseService.insertWallet(wallet);
                      ref.read(walletsProvider.notifier).load();
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Credit Card',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String label, {
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: context.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.subtitleColor),
        prefixIcon: icon != null
            ? Icon(icon, color: context.subtitleColor, size: 20)
            : null,
        filled: true,
        fillColor: context.isDark ? Colors.grey[800] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, Wallet wallet) {
    final usedCredit = wallet.usedCredit;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentBottomSheet(
        paymentType: PaymentType.credit,
        itemName: wallet.name,
        itemId: wallet.id,
        amountDue: usedCredit > 0 ? usedCredit : null,
        totalOutstanding: usedCredit,
        onPaymentComplete: () {},
      ),
    );
  }

  Widget _buildCreditCard(BuildContext context, Wallet wallet) {
    final creditLimit = wallet.creditLimit ?? 0;
    final usedCredit = wallet.usedCredit;
    final usagePercent = creditLimit > 0 ? usedCredit / creditLimit : 0.0;
    final now = DateTime.now();
    int daysLeft = 0;
    if (wallet.dueDay != null) {
      var dueDate = DateTime(now.year, now.month, wallet.dueDay!);
      if (dueDate.isBefore(now) || dueDate.isAtSameMomentAs(now)) {
        dueDate = DateTime(now.year, now.month + 1, wallet.dueDay!);
      }
      daysLeft = dueDate.difference(now).inDays;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppDecorations.cardShadow(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: AppColors.accent,
                  size: 22,
                ),
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
                    Text(
                      'Limit: ₱${NumberFormat('#,##0').format(creditLimit)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: usedCredit <= 0
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  usedCredit <= 0 ? 'Paid' : 'Pending',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: usedCredit <= 0
                        ? AppColors.primary
                        : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Used Credit',
                style: TextStyle(fontSize: 11, color: context.subtitleColor),
              ),
              Text(
                '₱${NumberFormat('#,##0.00').format(usedCredit)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: usagePercent.clamp(0.0, 1.0),
              backgroundColor: context.isDark
                  ? Colors.grey[700]
                  : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                usagePercent > 0.8 ? AppColors.error : AppColors.accent,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available: ₱${NumberFormat('#,##0.00').format(wallet.balance)}',
                style: TextStyle(fontSize: 11, color: context.subtitleColor),
              ),
              if (wallet.dueDay != null && daysLeft >= 0)
                Text(
                  'Due in $daysLeft days',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: daysLeft <= 7
                        ? AppColors.error
                        : context.subtitleColor,
                  ),
                ),
            ],
          ),
          if (usedCredit > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () => _showPaymentSheet(context, wallet),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Pay card',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
