class Debt {
  final int? id;
  final String name;
  final double totalAmount;
  final double remainingBalance;
  final String status; // Paid, Pending
  final List<DebtLog> logs;

  Debt({
    this.id,
    required this.name,
    required this.totalAmount,
    required this.remainingBalance,
    required this.status,
    this.logs = const [],
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'totalAmount': totalAmount,
    'remainingBalance': remainingBalance,
    'status': status,
  };

  factory Debt.fromMap(Map<String, dynamic> map, {List<DebtLog>? logs}) => Debt(
    id: map['id'] as int?,
    name: map['name'] as String,
    totalAmount: (map['totalAmount'] as num).toDouble(),
    remainingBalance: (map['remainingBalance'] as num).toDouble(),
    status: map['status'] as String,
    logs: logs ?? [],
  );
}

class DebtLog {
  final int? id;
  final int debtId;
  final DateTime date;
  final String? description;
  final double? amountPaid;
  final double? amountBorrowed;
  final String? paymentFrom;
  final double? remainingBalance;

  DebtLog({
    this.id,
    required this.debtId,
    required this.date,
    this.description,
    this.amountPaid,
    this.amountBorrowed,
    this.paymentFrom,
    this.remainingBalance,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'debtId': debtId,
    'date': date.toIso8601String(),
    'description': description,
    'amountPaid': amountPaid,
    'amountBorrowed': amountBorrowed,
    'paymentFrom': paymentFrom,
    'remainingBalance': remainingBalance,
  };

  factory DebtLog.fromMap(Map<String, dynamic> map) => DebtLog(
    id: map['id'] as int?,
    debtId: map['debtId'] as int,
    date: DateTime.parse(map['date'] as String),
    description: map['description'] as String?,
    amountPaid: map['amountPaid'] != null
        ? (map['amountPaid'] as num).toDouble()
        : null,
    amountBorrowed: map['amountBorrowed'] != null
        ? (map['amountBorrowed'] as num).toDouble()
        : null,
    paymentFrom: map['paymentFrom'] as String?,
    remainingBalance: map['remainingBalance'] != null
        ? (map['remainingBalance'] as num).toDouble()
        : null,
  );
}
