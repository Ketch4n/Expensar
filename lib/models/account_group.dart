class AccountGroup {
  final int? id;
  final String name;
  final int sortOrder;

  AccountGroup({this.id, required this.name, this.sortOrder = 0});

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'sortOrder': sortOrder,
  };

  factory AccountGroup.fromMap(Map<String, dynamic> map) => AccountGroup(
    id: map['id'] as int?,
    name: map['name'] as String,
    sortOrder: (map['sortOrder'] as int?) ?? 0,
  );

  AccountGroup copyWith({int? id, String? name, int? sortOrder}) =>
      AccountGroup(
        id: id ?? this.id,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
      );
}
