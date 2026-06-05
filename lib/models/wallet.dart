class Wallet {
  final int? id;
  final String name;
  double balance;
  final String type; // Debit, Credit, Loans, Assets, Stocks, Crypto
  final String? status;
  final DateTime? expectedPayoutDate;
  final bool isRecurring;
  final List<int> payDays;
  List<WalletLog> logs;

  // New fields for unified accounts
  final String currency;
  final String? notes;
  final bool includeInNetBalance;
  final int? groupId;
  final int sortOrder;

  // Credit-specific fields
  final double? creditLimit;
  final int? dueDay; // day of month
  final int? statementDay; // day of month

  // Loan-specific fields
  final double? paymentAmount;
  final int? totalPayments;
  final int? completedPayments;
  final DateTime? firstDueDate;
  final DateTime? loanStartDate;

  Wallet({
    this.id,
    required this.name,
    required this.balance,
    required this.type,
    this.status,
    this.expectedPayoutDate,
    this.logs = const [],
    this.isRecurring = false,
    this.payDays = const [],
    this.currency = 'PHP',
    this.notes,
    this.includeInNetBalance = true,
    this.groupId,
    this.sortOrder = 0,
    this.creditLimit,
    this.dueDay,
    this.statementDay,
    this.paymentAmount,
    this.totalPayments,
    this.completedPayments,
    this.firstDueDate,
    this.loanStartDate,
  });

  /// Whether this wallet is a liability (negative in net worth).
  bool get isLiability => type == 'Loans' || type == 'Credit';

  /// Whether this wallet is an asset (positive in net worth).
  bool get isAsset => !isLiability;

  /// For credit cards: used credit amount.
  double get usedCredit => creditLimit != null ? creditLimit! - balance : 0;

  /// For credit cards: usage percentage (0-100).
  double get creditUsagePercent => creditLimit != null && creditLimit! > 0
      ? ((creditLimit! - balance) / creditLimit!) * 100
      : 0;

  /// For loans: remaining payments.
  int get remainingPayments => (totalPayments ?? 0) - (completedPayments ?? 0);

  /// For loans: progress percentage (0-100).
  double get loanProgressPercent => totalPayments != null && totalPayments! > 0
      ? ((completedPayments ?? 0) / totalPayments!) * 100
      : 0;

  /// For loans: estimated end date.
  DateTime? get loanEndDate {
    if (firstDueDate == null || totalPayments == null) return null;
    return DateTime(
      firstDueDate!.year,
      firstDueDate!.month + (totalPayments! - 1),
      firstDueDate!.day,
    );
  }

  /// For loans: next due date based on completed payments.
  DateTime? get nextDueDate {
    if (firstDueDate == null || completedPayments == null) return null;
    return DateTime(
      firstDueDate!.year,
      firstDueDate!.month + completedPayments!,
      firstDueDate!.day,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'balance': balance,
    'type': type,
    'status': status,
    'expectedPayoutDate': expectedPayoutDate?.toIso8601String(),
    'isRecurring': isRecurring ? 1 : 0,
    'payDays': payDays.join(','),
    'currency': currency,
    'notes': notes,
    'includeInNetBalance': includeInNetBalance ? 1 : 0,
    'groupId': groupId,
    'sortOrder': sortOrder,
    'creditLimit': creditLimit,
    'dueDay': dueDay,
    'statementDay': statementDay,
    'paymentAmount': paymentAmount,
    'totalPayments': totalPayments,
    'completedPayments': completedPayments,
    'firstDueDate': firstDueDate?.toIso8601String(),
    'loanStartDate': loanStartDate?.toIso8601String(),
  };

  factory Wallet.fromMap(Map<String, dynamic> map, {List<WalletLog>? logs}) {
    final payDaysStr = map['payDays'] as String? ?? '';
    return Wallet(
      id: map['id'] as int?,
      name: map['name'] as String,
      balance: (map['balance'] as num).toDouble(),
      type: map['type'] as String,
      status: map['status'] as String?,
      expectedPayoutDate: map['expectedPayoutDate'] != null
          ? DateTime.parse(map['expectedPayoutDate'] as String)
          : null,
      isRecurring: (map['isRecurring'] as int? ?? 0) == 1,
      payDays: payDaysStr.isEmpty
          ? []
          : payDaysStr.split(',').map(int.parse).toList(),
      logs: logs ?? [],
      currency: map['currency'] as String? ?? 'PHP',
      notes: map['notes'] as String?,
      includeInNetBalance: (map['includeInNetBalance'] as int? ?? 1) == 1,
      groupId: map['groupId'] as int?,
      sortOrder: (map['sortOrder'] as int?) ?? 0,
      creditLimit: map['creditLimit'] != null
          ? (map['creditLimit'] as num).toDouble()
          : null,
      dueDay: map['dueDay'] as int?,
      statementDay: map['statementDay'] as int?,
      paymentAmount: map['paymentAmount'] != null
          ? (map['paymentAmount'] as num).toDouble()
          : null,
      totalPayments: map['totalPayments'] as int?,
      completedPayments: map['completedPayments'] as int?,
      firstDueDate: map['firstDueDate'] != null
          ? DateTime.parse(map['firstDueDate'] as String)
          : null,
      loanStartDate: map['loanStartDate'] != null
          ? DateTime.parse(map['loanStartDate'] as String)
          : null,
    );
  }

  Wallet copyWith({
    int? id,
    String? name,
    double? balance,
    String? type,
    String? status,
    DateTime? expectedPayoutDate,
    bool? isRecurring,
    List<int>? payDays,
    List<WalletLog>? logs,
    String? currency,
    String? notes,
    bool? includeInNetBalance,
    int? groupId,
    int? sortOrder,
    double? creditLimit,
    int? dueDay,
    int? statementDay,
    double? paymentAmount,
    int? totalPayments,
    int? completedPayments,
    DateTime? firstDueDate,
    DateTime? loanStartDate,
  }) => Wallet(
    id: id ?? this.id,
    name: name ?? this.name,
    balance: balance ?? this.balance,
    type: type ?? this.type,
    status: status ?? this.status,
    expectedPayoutDate: expectedPayoutDate ?? this.expectedPayoutDate,
    isRecurring: isRecurring ?? this.isRecurring,
    payDays: payDays ?? this.payDays,
    logs: logs ?? this.logs,
    currency: currency ?? this.currency,
    notes: notes ?? this.notes,
    includeInNetBalance: includeInNetBalance ?? this.includeInNetBalance,
    groupId: groupId ?? this.groupId,
    sortOrder: sortOrder ?? this.sortOrder,
    creditLimit: creditLimit ?? this.creditLimit,
    dueDay: dueDay ?? this.dueDay,
    statementDay: statementDay ?? this.statementDay,
    paymentAmount: paymentAmount ?? this.paymentAmount,
    totalPayments: totalPayments ?? this.totalPayments,
    completedPayments: completedPayments ?? this.completedPayments,
    firstDueDate: firstDueDate ?? this.firstDueDate,
    loanStartDate: loanStartDate ?? this.loanStartDate,
  );
}

class WalletLog {
  final int? id;
  final int walletId;
  final DateTime date;
  final String description;
  final double amount;
  final double? serviceCharge;
  final double postBalance;

  WalletLog({
    this.id,
    required this.walletId,
    required this.date,
    required this.description,
    required this.amount,
    this.serviceCharge,
    required this.postBalance,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'walletId': walletId,
    'date': date.toIso8601String(),
    'description': description,
    'amount': amount,
    'serviceCharge': serviceCharge,
    'postBalance': postBalance,
  };

  factory WalletLog.fromMap(Map<String, dynamic> map) => WalletLog(
    id: map['id'] as int?,
    walletId: map['walletId'] as int,
    date: DateTime.parse(map['date'] as String),
    description: map['description'] as String,
    amount: (map['amount'] as num).toDouble(),
    serviceCharge: map['serviceCharge'] != null
        ? (map['serviceCharge'] as num).toDouble()
        : null,
    postBalance: (map['postBalance'] as num).toDouble(),
  );
}
