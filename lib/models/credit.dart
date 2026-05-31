class Credit {
  final int? id;
  final String name;
  final double creditLimit;
  final double availableCredit;
  final double outstandingBalance;
  final DateTime dueDate;
  final String status; // Pending, Paid
  final List<CreditLog> logs;

  Credit({
    this.id,
    required this.name,
    required this.creditLimit,
    required this.availableCredit,
    required this.outstandingBalance,
    required this.dueDate,
    required this.status,
    this.logs = const [],
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'creditLimit': creditLimit,
    'availableCredit': availableCredit,
    'outstandingBalance': outstandingBalance,
    'dueDate': dueDate.toIso8601String(),
    'status': status,
  };

  factory Credit.fromMap(Map<String, dynamic> map, {List<CreditLog>? logs}) =>
      Credit(
        id: map['id'] as int?,
        name: map['name'] as String,
        creditLimit: (map['creditLimit'] as num).toDouble(),
        availableCredit: (map['availableCredit'] as num).toDouble(),
        outstandingBalance: (map['outstandingBalance'] as num).toDouble(),
        dueDate: DateTime.parse(map['dueDate'] as String),
        status: map['status'] as String,
        logs: logs ?? [],
      );
}

class CreditLog {
  final int? id;
  final int creditId;
  final DateTime date;
  final String description;
  final double amount;
  final double outstandingBalance;
  final double postAvailableCredit;

  CreditLog({
    this.id,
    required this.creditId,
    required this.date,
    required this.description,
    required this.amount,
    required this.outstandingBalance,
    required this.postAvailableCredit,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'creditId': creditId,
    'date': date.toIso8601String(),
    'description': description,
    'amount': amount,
    'outstandingBalance': outstandingBalance,
    'postAvailableCredit': postAvailableCredit,
  };

  factory CreditLog.fromMap(Map<String, dynamic> map) => CreditLog(
    id: map['id'] as int?,
    creditId: map['creditId'] as int,
    date: DateTime.parse(map['date'] as String),
    description: map['description'] as String,
    amount: (map['amount'] as num).toDouble(),
    outstandingBalance: (map['outstandingBalance'] as num).toDouble(),
    postAvailableCredit: (map['postAvailableCredit'] as num).toDouble(),
  );
}
