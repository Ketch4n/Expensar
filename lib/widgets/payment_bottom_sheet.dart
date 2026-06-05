import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../models/loan.dart';
import '../models/debt.dart';
import '../providers/data_providers.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

/// Payment type enum to differentiate between loan, credit, and debt payments.
enum PaymentType { loan, credit, debt }

/// A reusable payment bottom sheet for loans, credit cards, and debts.
class PaymentBottomSheet extends ConsumerStatefulWidget {
  final PaymentType paymentType;
  final String itemName;
  final double? amountDue;
  final double? totalOutstanding;
  final int? itemId;
  final VoidCallback? onPaymentComplete;

  const PaymentBottomSheet({
    super.key,
    required this.paymentType,
    required this.itemName,
    this.amountDue,
    this.totalOutstanding,
    this.itemId,
    this.onPaymentComplete,
  });

  @override
  ConsumerState<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends ConsumerState<PaymentBottomSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Wallet? _selectedWallet;
  List<Wallet> _debitWallets = [];

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    final wallets = await DatabaseService.getWallets();
    if (!mounted) return;
    setState(() {
      _debitWallets = wallets
          .where((w) => w.type == 'Debit' || w.type == 'Cash')
          .toList();
      if (_debitWallets.isNotEmpty) {
        _selectedWallet = _debitWallets.first;
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String get _typeLabel {
    switch (widget.paymentType) {
      case PaymentType.loan:
        return 'LOANS';
      case PaymentType.credit:
        return 'CREDIT';
      case PaymentType.debt:
        return 'DEBT';
    }
  }

  String get _title {
    switch (widget.paymentType) {
      case PaymentType.loan:
        return 'Add payment';
      case PaymentType.credit:
        return 'Pay card';
      case PaymentType.debt:
        return 'Log payment';
    }
  }

  String get _subtitle {
    switch (widget.paymentType) {
      case PaymentType.loan:
        return 'Log a payment for ${widget.itemName}.';
      case PaymentType.credit:
        return 'Pay your ${widget.itemName} balance.';
      case PaymentType.debt:
        return 'Record a payment for ${widget.itemName} from cash or move it onto another credit card as a balance transfer.';
    }
  }

  String get _buttonLabel {
    switch (widget.paymentType) {
      case PaymentType.loan:
        return 'Add payment';
      case PaymentType.credit:
        return 'Pay card';
      case PaymentType.debt:
        return 'Add payment';
    }
  }

  Color get _typeColor {
    switch (widget.paymentType) {
      case PaymentType.loan:
        return AppColors.error;
      case PaymentType.credit:
        return AppColors.accent;
      case PaymentType.debt:
        return AppColors.warning;
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _fillAmountDue() {
    if (widget.amountDue != null && widget.amountDue! > 0) {
      setState(() {
        _amountController.text = widget.amountDue!.toStringAsFixed(2);
      });
    }
  }

  double get _paymentAmount {
    return double.tryParse(_amountController.text) ?? 0;
  }

  Future<void> _submitPayment() async {
    final amount = _paymentAmount;
    if (amount <= 0) return;
    if (_selectedWallet == null) return;

    final wallet = _selectedWallet!;
    final note = _noteController.text.trim();

    // Deduct from wallet
    final newBalance = wallet.balance - amount;
    final updatedWallet = wallet.copyWith(balance: newBalance);
    await DatabaseService.updateWallet(updatedWallet);

    // Log the wallet transaction
    final walletLog = WalletLog(
      walletId: wallet.id!,
      date: _selectedDate,
      description:
          'Payment to ${widget.itemName}${note.isNotEmpty ? ' - $note' : ''}',
      amount: amount,
      postBalance: newBalance,
    );
    await DatabaseService.insertWalletLog(walletLog);

    // Update the specific item based on type
    switch (widget.paymentType) {
      case PaymentType.loan:
        await _processLoanPayment(amount, note);
        break;
      case PaymentType.credit:
        await _processCreditPayment(amount, note);
        break;
      case PaymentType.debt:
        await _processDebtPayment(amount, note);
        break;
    }

    // Refresh providers
    ref.read(walletsProvider.notifier).load();
    ref.read(loansProvider.notifier).load();
    ref.read(creditsProvider.notifier).load();
    ref.read(debtsProvider.notifier).load();

    widget.onPaymentComplete?.call();

    if (mounted) Navigator.pop(context);
  }

  Future<void> _processLoanPayment(double amount, String note) async {
    if (widget.itemId == null) return;
    final loans = await DatabaseService.getLoans();
    final loan = loans.firstWhere((l) => l.id == widget.itemId);

    final updatedLoan = Loan(
      id: loan.id,
      name: loan.name,
      balance: loan.balance - amount,
      paidAmount: loan.paidAmount + amount,
      type: loan.type,
      principalAmount: loan.principalAmount,
      netProceeds: loan.netProceeds,
      interestRate: loan.interestRate,
      loanTerm: loan.loanTerm,
      processingFee: loan.processingFee,
      adminFee: loan.adminFee,
    );
    await DatabaseService.updateLoan(updatedLoan);
  }

  Future<void> _processCreditPayment(double amount, String note) async {
    // Credits are stored as wallets with type 'Credit'
    if (widget.itemId == null) return;
    final wallets = await DatabaseService.getWallets();
    final creditWallet = wallets.firstWhere((w) => w.id == widget.itemId);

    // Paying a credit card increases available credit (balance)
    final updatedCredit = creditWallet.copyWith(
      balance: creditWallet.balance + amount,
    );
    await DatabaseService.updateWallet(updatedCredit);

    // Log on the credit card
    final creditLog = WalletLog(
      walletId: creditWallet.id!,
      date: _selectedDate,
      description: 'Payment received${note.isNotEmpty ? ' - $note' : ''}',
      amount: amount,
      postBalance: updatedCredit.balance,
    );
    await DatabaseService.insertWalletLog(creditLog);
  }

  Future<void> _processDebtPayment(double amount, String note) async {
    if (widget.itemId == null) return;
    final debts = await DatabaseService.getDebts();
    final debt = debts.firstWhere((d) => d.id == widget.itemId);

    final newRemaining = (debt.remainingBalance - amount).clamp(
      0.0,
      debt.totalAmount,
    );
    final newStatus = newRemaining <= 0 ? 'Paid' : 'Pending';

    final updatedDebt = Debt(
      id: debt.id,
      name: debt.name,
      totalAmount: debt.totalAmount,
      remainingBalance: newRemaining,
      status: newStatus,
    );
    await DatabaseService.updateDebt(updatedDebt);

    // Insert debt log
    final debtLog = DebtLog(
      debtId: debt.id!,
      date: _selectedDate,
      description: note.isNotEmpty
          ? note
          : 'Payment from ${_selectedWallet?.name ?? "Cash"}',
      amountPaid: amount,
      paymentFrom: _selectedWallet?.name ?? 'Cash',
      remainingBalance: newRemaining,
    );
    await DatabaseService.insertDebtLog(debtLog);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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
            // Type label and title
            Text(
              _typeLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _typeColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _title,
              style: AppTextStyles.heading.copyWith(
                color: context.textPrimary,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _subtitle,
              style: TextStyle(fontSize: 13, color: context.subtitleColor),
            ),

            const SizedBox(height: 24),
            // Payment amount section
            Text(
              'PAYMENT AMOUNT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.subtitleColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  fontSize: 18,
                  color: context.subtitleColor,
                ),
                filled: true,
                fillColor: context.isDark ? Colors.grey[800] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),

            // Quick amount buttons for debt type or autofill for credit/loan
            if (widget.paymentType == PaymentType.debt) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _quickAmountChip(500),
                  const SizedBox(width: 8),
                  _quickAmountChip(1000),
                  const SizedBox(width: 8),
                  _quickAmountChip(5000),
                ],
              ),
            ],
            // Autofill amount due button for credit/loan
            if (widget.amountDue != null &&
                widget.amountDue! > 0 &&
                widget.paymentType != PaymentType.debt) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _fillAmountDue,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.paymentType == PaymentType.credit
                                  ? 'Pay Current Amount Due'
                                  : 'Pay Next Installment',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₱${NumberFormat('#,##0.00').format(widget.amountDue)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.auto_fix_high_rounded,
                        color: context.subtitleColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              if (widget.paymentType == PaymentType.credit) ...[
                const SizedBox(height: 8),
                Text(
                  'Autofills the current amount due of ₱${NumberFormat('#,##0.00').format(widget.amountDue)}. This total can include installment dues, and you can still edit it after.',
                  style: TextStyle(fontSize: 12, color: context.subtitleColor),
                ),
              ],
            ],
            const SizedBox(height: 20),
            // Payment date
            Text(
              'PAYMENT DATE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.subtitleColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: context.isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMMM d, yyyy').format(_selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Use this date in history, sorting, and reports',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_rounded,
                      color: context.subtitleColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Pay from section
            Text(
              'PAY FROM',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.subtitleColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showWalletPicker,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: context.isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedWallet?.name ?? 'Cash',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            _selectedWallet != null
                                ? '₱${NumberFormat('#,##0.00').format(_selectedWallet!.balance)} · ${_selectedWallet!.currency}'
                                : 'Select a wallet',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.subtitleColor,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Note (optional)
            Text(
              'NOTE (OPTIONAL)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.subtitleColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              style: TextStyle(color: context.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Paid after cutoff',
                hintStyle: TextStyle(color: context.subtitleColor),
                filled: true,
                fillColor: context.isDark ? Colors.grey[800] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Payment preview
            if (_paymentAmount > 0 && _selectedWallet != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment preview',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₱${NumberFormat('#,##0.00').format(_paymentAmount)} from ${_selectedWallet!.name}',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _paymentAmount > 0 ? _submitPayment : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _paymentAmount > 0
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          _buttonLabel,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _paymentAmount > 0
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _quickAmountChip(double amount) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _amountController.text = amount.toStringAsFixed(2);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: context.isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.isDark ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          '₱${NumberFormat('#,##0.00').format(amount)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
      ),
    );
  }

  void _showWalletPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Wallet',
              style: AppTextStyles.heading.copyWith(
                color: context.textPrimary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            ..._debitWallets.map(
              (wallet) => GestureDetector(
                onTap: () {
                  setState(() => _selectedWallet = wallet);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: _selectedWallet?.id == wallet.id
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          wallet.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '₱${NumberFormat('#,##0.00').format(wallet.balance)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
