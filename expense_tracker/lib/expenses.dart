import 'package:expense_tracker/expenses_list.dart';
import 'package:expense_tracker/model/expense.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _expenseList = [
    Expense(
      amount: 20000,
      title: 'Food',
      category: Category.food,
      date: DateTime.now(),
    ),
    Expense(
      amount: 1000,
      title: 'Leisure',
      category: Category.leisure,
      date: DateTime(2024, 1, 1),
    ),
    Expense(
      amount: 5000,
      title: 'Transportation',
      category: Category.transportation,
      date: DateTime.now(),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('chart'),
          Expanded(child: ExpensesList(expenses: _expenseList)),
        ],
      ),
    );
  }
}
