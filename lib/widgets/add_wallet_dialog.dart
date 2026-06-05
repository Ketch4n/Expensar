import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../models/account_group.dart';
import '../providers/data_providers.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class AddWalletDialog extends ConsumerStatefulWidget {
  final Wallet? editWallet;

  const AddWalletDialog({super.key, this.editWallet});

  @override
  ConsumerState<AddWalletDialog> createState() => _AddWalletDialogState();
}

class _AddWalletDialogState extends ConsumerState<AddWalletDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _notesController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _dueDayController = TextEditingController();
  final _statementDayController = TextEditingController();
  final _paymentAmountController = TextEditingController();
  final _totalPaymentsController = TextEditingController();
  final _completedPaymentsController = TextEditingController();

  String _selectedType = 'Debit';
  String _currency = 'PHP';
  bool _includeInNetBalance = true;
  int? _selectedGroupId;
  DateTime? _firstDueDate;
  DateTime? _loanStartDate;

  bool get _isEditing => widget.editWallet != null;

  static const _walletTypes = [
    'Debit',
    'Credit',
    'Loans',
    'Assets',
    'Stocks',
    'Crypto',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final w = widget.editWallet!;
      _nameController.text = w.name;
      _balanceController.text = w.balance.toStringAsFixed(2);
      _selectedType = w.type;
      _currency = w.currency;
      _includeInNetBalance = w.includeInNetBalance;
      _selectedGroupId = w.groupId;
      _notesController.text = w.notes ?? '';
      _creditLimitController.text = w.creditLimit?.toStringAsFixed(2) ?? '';
      _dueDayController.text = w.dueDay?.toString() ?? '';
      _statementDayController.text = w.statementDay?.toString() ?? '';
      _paymentAmountController.text = w.paymentAmount?.toStringAsFixed(2) ?? '';
      _totalPaymentsController.text = w.totalPayments?.toString() ?? '';
      _completedPaymentsController.text = w.completedPayments?.toString() ?? '';
      _firstDueDate = w.firstDueDate;
      _loanStartDate = w.loanStartDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _notesController.dispose();
    _creditLimitController.dispose();
    _dueDayController.dispose();
    _statementDayController.dispose();
    _paymentAmountController.dispose();
    _totalPaymentsController.dispose();
    _completedPaymentsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final wallet = Wallet(
      id: widget.editWallet?.id,
      name: _nameController.text.trim(),
      balance: double.parse(_balanceController.text),
      type: _selectedType,
      currency: _currency,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      includeInNetBalance: _includeInNetBalance,
      groupId: _selectedGroupId,
      isRecurring: widget.editWallet?.isRecurring ?? false,
      payDays: widget.editWallet?.payDays ?? [],
      status: widget.editWallet?.status,
      expectedPayoutDate: widget.editWallet?.expectedPayoutDate,
      creditLimit: _creditLimitController.text.isNotEmpty
          ? double.parse(_creditLimitController.text)
          : null,
      dueDay: _dueDayController.text.isNotEmpty
          ? int.parse(_dueDayController.text)
          : null,
      statementDay: _statementDayController.text.isNotEmpty
          ? int.parse(_statementDayController.text)
          : null,
      paymentAmount: _paymentAmountController.text.isNotEmpty
          ? double.parse(_paymentAmountController.text)
          : null,
      totalPayments: _totalPaymentsController.text.isNotEmpty
          ? int.parse(_totalPaymentsController.text)
          : null,
      completedPayments: _completedPaymentsController.text.isNotEmpty
          ? int.parse(_completedPaymentsController.text)
          : null,
      firstDueDate: _firstDueDate,
      loanStartDate: _loanStartDate,
    );

    if (_isEditing) {
      await DatabaseService.updateWallet(wallet);
    } else {
      await DatabaseService.insertWallet(wallet);
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _pickDate(bool isFirstDue) async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          (isFirstDue ? _firstDueDate : _loanStartDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date != null) {
      setState(() {
        if (isFirstDue) {
          _firstDueDate = date;
        } else {
          _loanStartDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(accountGroupsProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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
                  _isEditing ? 'Edit Account' : 'Add Account',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                // Account Type
                _buildSectionLabel(context, 'ACCOUNT TYPE'),
                const SizedBox(height: 10),
                _buildTypeSelector(context),
                const SizedBox(height: 20),
                // Account Name
                _buildSectionLabel(context, 'ACCOUNT NAME'),
                const SizedBox(height: 10),
                _buildTextField(
                  _nameController,
                  'Account name',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                // Currency
                _buildSectionLabel(context, 'ACCOUNT CURRENCY'),
                const SizedBox(height: 10),
                _buildCurrencySelector(context),
                const SizedBox(height: 20),
                // Balance
                _buildSectionLabel(context, _getBalanceLabel()),
                const SizedBox(height: 10),
                _buildTextField(
                  _balanceController,
                  'Amount',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Invalid';
                    return null;
                  },
                ),
                // Type-specific fields
                if (_selectedType == 'Credit') ..._buildCreditFields(context),
                if (_selectedType == 'Loans') ..._buildLoanFields(context),
                const SizedBox(height: 20),
                // Notes
                _buildSectionLabel(context, 'Notes (optional)'),
                const SizedBox(height: 10),
                _buildTextField(_notesController, 'Notes', maxLines: 3),
                const SizedBox(height: 20),
                // Include in net balance
                _buildToggle(context),
                const SizedBox(height: 16),
                // Account Group
                _buildGroupSelector(context, groups),
                const SizedBox(height: 24),
                // Buttons
                _buildButtons(context),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: context.subtitleColor,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: context.scaffoldBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _walletTypes.map((type) {
        final isSelected = _selectedType == type;
        final (icon, color) = switch (type) {
          'Debit' => (Icons.credit_card, AppColors.secondary),
          'Credit' => (Icons.credit_score, const Color(0xFFE91E63)),
          'Loans' => (Icons.handshake, AppColors.warning),
          'Assets' => (Icons.account_balance, AppColors.primary),
          'Stocks' => (Icons.show_chart, const Color(0xFF9C27B0)),
          'Crypto' => (Icons.currency_bitcoin, const Color(0xFFF57C00)),
          _ => (Icons.wallet, Colors.grey),
        };
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.1)
                  : context.chipBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : context.dividerColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? color : context.subtitleColor,
                ),
                const SizedBox(width: 6),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? color : context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          Text(
            _currency,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getCurrencyName(_currency),
            style: TextStyle(fontSize: 13, color: context.subtitleColor),
          ),
          const Spacer(),
          Icon(Icons.chevron_right, color: context.subtitleColor, size: 20),
        ],
      ),
    );
  }

  String _getCurrencyName(String code) {
    return switch (code) {
      'PHP' => 'Philippine Peso',
      'USD' => 'US Dollar',
      'EUR' => 'Euro',
      _ => code,
    };
  }

  String _getBalanceLabel() {
    return switch (_selectedType) {
      'Loans' => 'CURRENT AMOUNT OWED',
      'Credit' => 'CURRENT BALANCE',
      _ => 'INITIAL BALANCE',
    };
  }

  List<Widget> _buildCreditFields(BuildContext context) {
    return [
      const SizedBox(height: 20),
      _buildSectionLabel(context, 'CREDIT LIMIT'),
      const SizedBox(height: 10),
      _buildTextField(
        _creditLimitController,
        'Credit limit',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel(context, 'DUE DAY'),
                const SizedBox(height: 10),
                _buildTextField(
                  _dueDayController,
                  'Day',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel(context, 'STATEMENT DAY'),
                const SizedBox(height: 10),
                _buildTextField(
                  _statementDayController,
                  'Day',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildLoanFields(BuildContext context) {
    return [
      const SizedBox(height: 20),
      _buildSectionLabel(context, 'LOAN SCHEDULE'),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment amount',
                  style: TextStyle(fontSize: 12, color: context.subtitleColor),
                ),
                const SizedBox(height: 6),
                _buildTextField(
                  _paymentAmountController,
                  'Amount',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total payments',
                  style: TextStyle(fontSize: 12, color: context.subtitleColor),
                ),
                const SizedBox(height: 6),
                _buildTextField(
                  _totalPaymentsController,
                  'Count',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completed',
                  style: TextStyle(fontSize: 12, color: context.subtitleColor),
                ),
                const SizedBox(height: 6),
                _buildTextField(
                  _completedPaymentsController,
                  'Count',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First due date',
                  style: TextStyle(fontSize: 12, color: context.subtitleColor),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _pickDate(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: context.scaffoldBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.dividerColor),
                    ),
                    child: Text(
                      _firstDueDate != null
                          ? DateFormat('yyyy-MM-dd').format(_firstDueDate!)
                          : 'Select',
                      style: TextStyle(
                        fontSize: 14,
                        color: _firstDueDate != null
                            ? context.textPrimary
                            : context.subtitleColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        'Loan start date',
        style: TextStyle(fontSize: 12, color: context.subtitleColor),
      ),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () => _pickDate(false),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.scaffoldBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.dividerColor),
          ),
          child: Text(
            _loanStartDate != null
                ? DateFormat('yyyy-MM-dd').format(_loanStartDate!)
                : 'Select',
            style: TextStyle(
              fontSize: 14,
              color: _loanStartDate != null
                  ? context.textPrimary
                  : context.subtitleColor,
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Include in net balance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Count this account in the app\'s overall net balance.',
                  style: TextStyle(fontSize: 12, color: context.subtitleColor),
                ),
              ],
            ),
          ),
          Switch(
            value: _includeInNetBalance,
            onChanged: (v) => setState(() => _includeInNetBalance = v),
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSelector(BuildContext context, List<AccountGroup> groups) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: context.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: _selectedGroupId,
          isExpanded: true,
          hint: Text(
            'Account Group',
            style: TextStyle(color: context.subtitleColor),
          ),
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('None')),
            ...groups.map(
              (g) => DropdownMenuItem<int?>(value: g.id, child: Text(g.name)),
            ),
          ],
          onChanged: (v) => setState(() => _selectedGroupId = v),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(color: context.dividerColor),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                _isEditing ? 'Save' : 'Add Account',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
