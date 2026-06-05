import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/loan.dart';
import '../providers/data_providers.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/payment_bottom_sheet.dart';

class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loans = ref.watch(loansProvider);
    final totalBalance = loans.fold<double>(0, (sum, l) => sum + l.balance);
    final totalPaid = loans.fold<double>(0, (sum, l) => sum + l.paidAmount);

    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Loans',
              trailing: GestureDetector(
                onTap: () => _showAddLoanDialog(context, ref),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: AppDecorations.card(context),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL OUTSTANDING',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.subtitleColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₱${NumberFormat('#,##0.00').format(totalBalance)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'TOTAL PAID',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.subtitleColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₱${NumberFormat('#,##0.00').format(totalPaid)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: loans.isEmpty
                  ? Center(
                      child: Text(
                        'No loans yet',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: loans.length,
                      itemBuilder: (context, index) =>
                          _buildLoanCard(context, loans[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCard(BuildContext context, Loan loan) {
    final progress = loan.paidAmount / (loan.balance + loan.paidAmount);
    final nextPayment =
        loan.transactions.where((t) => t.status == 'Upcoming').toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return GestureDetector(
      onTap: () => _showLoanDetails(context, loan),
      child: Container(
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
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppColors.error,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.name,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        '${loan.loanTerm} • ${loan.interestRate}% interest',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₱${NumberFormat('#,##0.00').format(loan.balance)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: context.isDark
                    ? Colors.grey[700]
                    : Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paid: ₱${NumberFormat('#,##0.00').format(loan.paidAmount)}',
                  style: TextStyle(fontSize: 11, color: context.subtitleColor),
                ),
                if (nextPayment.isNotEmpty)
                  Text(
                    'Next: ${DateFormat('MMM d').format(nextPayment.first.dueDate)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLoanDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final principalController = TextEditingController();
    final interestController = TextEditingController();
    final termController = TextEditingController();
    final processingFeeController = TextEditingController();

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
                  'Add Loan',
                  style: AppTextStyles.heading.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  context,
                  nameController,
                  'Loan Name',
                  icon: Icons.receipt_long,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  context,
                  principalController,
                  'Principal Amount',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  context,
                  interestController,
                  'Interest Rate (%)',
                  icon: Icons.percent,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  context,
                  termController,
                  'Loan Term (e.g. 12 months)',
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  context,
                  processingFeeController,
                  'Processing Fee (optional)',
                  icon: Icons.money_off,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final principal = double.tryParse(
                        principalController.text.trim(),
                      );
                      final interest = double.tryParse(
                        interestController.text.trim(),
                      );
                      final term = termController.text.trim();

                      if (name.isEmpty ||
                          principal == null ||
                          interest == null ||
                          term.isEmpty) {
                        return;
                      }

                      final processingFee = double.tryParse(
                        processingFeeController.text.trim(),
                      );
                      final netProceeds = principal - (processingFee ?? 0);

                      final loan = Loan(
                        name: name,
                        balance: principal,
                        paidAmount: 0,
                        type: 'Personal Loan',
                        principalAmount: principal,
                        netProceeds: netProceeds,
                        interestRate: interest,
                        loanTerm: term,
                        processingFee: processingFee,
                      );

                      await DatabaseService.insertLoan(loan);
                      ref.read(loansProvider.notifier).load();
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
                      'Add Loan',
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

  void _showLoanDetails(BuildContext context, Loan loan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(sheetContext).size.height * 0.75,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loan.name,
                    style: AppTextStyles.heading.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _infoChip(
                        context,
                        'Principal',
                        '₱${NumberFormat('#,##0').format(loan.principalAmount)}',
                      ),
                      const SizedBox(width: 8),
                      _infoChip(context, 'Rate', '${loan.interestRate}%'),
                      const SizedBox(width: 8),
                      _infoChip(context, 'Term', loan.loanTerm),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showPaymentSheet(context, loan);
                  },
                  icon: const Icon(Icons.payment_rounded, size: 18),
                  label: const Text('Add Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: context.dividerColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Payment Schedule',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: loan.transactions.length,
                itemBuilder: (sheetContext, index) {
                  final tx = loan.transactions[index];
                  final isPaid = tx.status == 'Paid';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          isPaid
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isPaid
                              ? AppColors.primary
                              : context.subtitleColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.month,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: context.textPrimary,
                                ),
                              ),
                              Text(
                                DateFormat('MMM d, yyyy').format(tx.dueDate),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₱${NumberFormat('#,##0.00').format(tx.amountDue)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isPaid
                                ? AppColors.primary
                                : context.textPrimary,
                          ),
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

  void _showPaymentSheet(BuildContext context, Loan loan) {
    final nextPayment =
        loan.transactions.where((t) => t.status == 'Upcoming').toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final amountDue = nextPayment.isNotEmpty
        ? nextPayment.first.amountDue
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentBottomSheet(
        paymentType: PaymentType.loan,
        itemName: loan.name,
        itemId: loan.id,
        amountDue: amountDue,
        totalOutstanding: loan.balance,
        onPaymentComplete: () {},
      ),
    );
  }

  Widget _infoChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.chipBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: context.subtitleColor),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
