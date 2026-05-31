class Wallet {
  final int? id;
  final String name;
  double balance;
  final String type; // Payroll, E-Wallet, Cash
  final String? status;
  final DateTime? expectedPayoutDate;
  final bool isRecurring;
  final List<int> payDays;
  List<WalletLog> logs;

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
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'balance': balance,
    'type': type,
    'status': status,
    'expectedPayoutDate': expectedPayoutDate?.toIso8601String(),
    'isRecurring': isRecurring ? 1 : 0,
    'payDays': payDays.join(','),
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
    );
  }

  Wallet copyWith({int? id, double? balance}) => Wallet(
    id: id ?? this.id,
    name: name,
    balance: balance ?? this.balance,
    type: type,
    status: status,
    expectedPayoutDate: expectedPayoutDate,
    isRecurring: isRecurring,
    payDays: payDays,
    logs: logs,
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
