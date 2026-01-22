import 'package:flutter/material.dart';

enum Categories {
  dairy,
  fruits,
  carbs,
  spices,
  hygiene,
  sweets,
  meat,
  fruit,
  vegetables,
  other,
  convenience,
}

class Category {
  final String title;
  final Color color;

  const Category(this.title, this.color);
}
