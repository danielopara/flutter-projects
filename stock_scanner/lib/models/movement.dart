enum MovementType { stockIn, stockOut, adjust, initial }

extension MovementTypeX on MovementType {
  String get label => switch (this) {
    MovementType.stockIn => 'Stock In',
    MovementType.stockOut => 'Stock Out',
    MovementType.adjust => 'Adjust',
    MovementType.initial => 'Initial',
  };
}

class Movement {
  final String id;
  final String itemId;
  final MovementType type;
  final double delta;
  final double balanceAfter;
  final String note;
  final DateTime createdAt;

  const Movement({
    required this.id,
    required this.itemId,
    required this.type,
    required this.delta,
    required this.balanceAfter,
    this.note = '',
    required this.createdAt,
  });

  Map<String, Object> toMap() => {
    'id': id,
    'item_id': itemId,
    'type': type.name,
    'delta': delta,
    'balance_after': balanceAfter,
    'note': note,
    'created_at': createdAt.toIso8601String(),
  };

  factory Movement.fromMap(Map<String, Object?> map) => Movement(
    id: map['id'] as String,
    itemId: map['item_id'] as String,
    type: MovementType.values.firstWhere(
      (t) => t.name == map['type'],
      orElse: () => MovementType.adjust,
    ),
    delta: (map['delta'] as num).toDouble(),
    balanceAfter: (map['balance_after'] as num).toDouble(),
    note: map['note'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
