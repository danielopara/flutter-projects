enum Category {
  tops,
  trousers,
  shoes,
  caps,
  accessories,
  underwear;

  String get label => switch (this) {
    Category.accessories => 'Accessories',
    Category.tops => 'Tops',
    Category.trousers => 'Trousers',
    Category.shoes => 'Shoes',
    Category.caps => 'Caps',
    Category.underwear => 'Underwear',
  };
}

class Garment {
  final String id;
  final String name;
  final Category category;
  final List<String> colors;
  final int quantity;
  final String? imagePath;

  const Garment({
    required this.id,
    required this.name,
    required this.category,
    required this.colors,
    required this.quantity,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.name,
    'quantity': quantity,
    'imagePath': imagePath,
    'colors': colors,
  };

  factory Garment.fromJson(Map<String, dynamic> json) => Garment(
    id: json['id'] as String,
    name: json['name'] as String,
    category: Category.values.byName(json['category'] as String),
    colors: (json['colors'] as List).cast<String>(),
    quantity: (json['quantity'] as num).toInt(),
    imagePath: json['imagePath'] as String?,
  );

  Garment copyWith({
    String? name,
    Category? category,
    int? quantity,
    String? imagePath,
    List<String>? colors,
  }) => Garment(
    id: id,
    name: name ?? this.name,
    category: category ?? this.category,
    colors: colors ?? this.colors,
    quantity: quantity ?? this.quantity,
    imagePath: imagePath ?? this.imagePath,
  );
}
