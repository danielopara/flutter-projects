class Item {
  final String id;
  final String name;
  final String barcode;
  final String sku;
  final double quantity;
  final String unit;
  final String location;
  final double lowStockThreshold;
  final DateTime updatedAt;

  const Item({
    required this.id,
    required this.name,
    required this.barcode,
    required this.sku,
    required this.quantity,
    required this.unit,
    required this.location,
    required this.lowStockThreshold,
    required this.updatedAt,
  });

  Item copyWith({
    String? name,
    String? barcode,
    String? sku,
    double? quantity,
    String? unit,
    String? location,
    double? lowStockThreshold,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      location: location ?? this.location,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object> toMap() => {
    'id': id,
    'barcode': barcode,
    'name': name,
    'sku': sku,
    'quantity': quantity,
    'unit': unit,
    'location': location,
    'low_stock_threshold': lowStockThreshold,
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Item.fromMap(Map<String, Object?> map) => Item(
    id: map['id'] as String,
    name: map['name'] as String,
    barcode: map['barcode'] as String,
    sku: map['sku'] as String? ?? '',
    quantity: (map['quantity'] as num).toDouble(),
    unit: map['unit'] as String? ?? 'pcs',
    location: map['location'] as String? ?? '',
    lowStockThreshold: (map['low_stock_threshold'] as num?)?.toDouble() ?? 0,
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );

  bool get isLowStock => lowStockThreshold > 0 && quantity <= lowStockThreshold;
}
