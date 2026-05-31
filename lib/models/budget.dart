class Budget {
  final int? id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final String status; // Upcoming, Paid, Overdue
  final String category; // budget, subscription
  final String? description;

  Budget({
    this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.category,
    this.description,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'amount': amount,
    'dueDate': dueDate.toIso8601String(),
    'status': status,
    'category': category,
    'description': description,
  };

  factory Budget.fromMap(Map<String, dynamic> map) => Budget(
    id: map['id'] as int?,
    name: map['name'] as String,
    amount: (map['amount'] as num).toDouble(),
    dueDate: DateTime.parse(map['dueDate'] as String),
    status: map['status'] as String,
    category: map['category'] as String,
    description: map['description'] as String?,
  );
}
