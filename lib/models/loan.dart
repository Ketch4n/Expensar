class Loan {
  final int? id;
  final String name;
  final double balance;
  final double paidAmount;
  final String type; // Personal Loan
  final double principalAmount;
  final double netProceeds;
  final double interestRate;
  final String loanTerm;
  final double? processingFee;
  final double? adminFee;
  final List<LoanTransaction> transactions;

  Loan({
    this.id,
    required this.name,
    required this.balance,
    required this.paidAmount,
    required this.type,
    required this.principalAmount,
    required this.netProceeds,
    required this.interestRate,
    required this.loanTerm,
    this.processingFee,
    this.adminFee,
    this.transactions = const [],
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'balance': balance,
    'paidAmount': paidAmount,
    'type': type,
    'principalAmount': principalAmount,
    'netProceeds': netProceeds,
    'interestRate': interestRate,
    'loanTerm': loanTerm,
    'processingFee': processingFee,
    'adminFee': adminFee,
  };

  factory Loan.fromMap(
    Map<String, dynamic> map, {
    List<LoanTransaction>? transactions,
  }) => Loan(
    id: map['id'] as int?,
    name: map['name'] as String,
    balance: (map['balance'] as num).toDouble(),
    paidAmount: (map['paidAmount'] as num).toDouble(),
    type: map['type'] as String,
    principalAmount: (map['principalAmount'] as num).toDouble(),
    netProceeds: (map['netProceeds'] as num).toDouble(),
    interestRate: (map['interestRate'] as num).toDouble(),
    loanTerm: map['loanTerm'] as String,
    processingFee: map['processingFee'] != null
        ? (map['processingFee'] as num).toDouble()
        : null,
    adminFee: map['adminFee'] != null
        ? (map['adminFee'] as num).toDouble()
        : null,
    transactions: transactions ?? [],
  );
}

class LoanTransaction {
  final int? id;
  final int loanId;
  final String month;
  final DateTime dueDate;
  final double amountDue;
  final String status; // Upcoming, Paid
  final DateTime? paidDate;
  final double? paidAmount;
  final String? description;

  LoanTransaction({
    this.id,
    required this.loanId,
    required this.month,
    required this.dueDate,
    required this.amountDue,
    required this.status,
    this.paidDate,
    this.paidAmount,
    this.description,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'loanId': loanId,
    'month': month,
    'dueDate': dueDate.toIso8601String(),
    'amountDue': amountDue,
    'status': status,
    'paidDate': paidDate?.toIso8601String(),
    'paidAmount': paidAmount,
    'description': description,
  };

  factory LoanTransaction.fromMap(Map<String, dynamic> map) => LoanTransaction(
    id: map['id'] as int?,
    loanId: map['loanId'] as int,
    month: map['month'] as String,
    dueDate: DateTime.parse(map['dueDate'] as String),
    amountDue: (map['amountDue'] as num).toDouble(),
    status: map['status'] as String,
    paidDate: map['paidDate'] != null
        ? DateTime.parse(map['paidDate'] as String)
        : null,
    paidAmount: map['paidAmount'] != null
        ? (map['paidAmount'] as num).toDouble()
        : null,
    description: map['description'] as String?,
  );
}
