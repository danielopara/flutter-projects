import 'package:flutter/material.dart';

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

  IconData get icon => switch (this) {
    Category.tops => Icons.checkroom,
    Category.trousers => Icons.straighten,
    Category.shoes => Icons.ice_skating,
    Category.caps => Icons.face,
    Category.accessories => Icons.watch,
    Category.underwear => Icons.dry_cleaning,
  };
}

/// The fixed palette a garment's colors are picked from. Garments store the
/// color *name* so the file stays readable and stable across theme changes.
const Map<String, Color> garmentPalette = {
  'Black': Color(0xFF212121),
  'White': Color(0xFFFAFAFA),
  'Grey': Color(0xFF9E9E9E),
  'Navy': Color(0xFF1A237E),
  'Blue': Color(0xFF1E88E5),
  'Green': Color(0xFF43A047),
  'Olive': Color(0xFF827717),
  'Yellow': Color(0xFFFDD835),
  'Orange': Color(0xFFFB8C00),
  'Red': Color(0xFFE53935),
  'Pink': Color(0xFFF06292),
  'Purple': Color(0xFF8E24AA),
  'Brown': Color(0xFF6D4C41),
  'Beige': Color(0xFFD7C4A3),
};

class Garment {
  final String id;
  final String name;
  final Category category;
  final List<String> colors;
  final int quantity;

  /// File name of the photo inside the store's images directory (not an
  /// absolute path — app container paths change between installs on iOS).
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
    bool clearImage = false,
    List<String>? colors,
  }) => Garment(
    id: id,
    name: name ?? this.name,
    category: category ?? this.category,
    colors: colors ?? this.colors,
    quantity: quantity ?? this.quantity,
    imagePath: clearImage ? null : imagePath ?? this.imagePath,
  );
}
