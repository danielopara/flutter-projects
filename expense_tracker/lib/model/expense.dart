import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

final uuid = Uuid();

final formatter = DateFormat.yMd();

enum Category { food, leisure, transportation, data }

const categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.leisure: Icons.movie,
  Category.transportation: Icons.bus_alert,
  Category.data: Icons.wifi,
};

class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  }) : id = uuid.v4();

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  String get formattedDate {
    return formatter.format(date);
  }
}
