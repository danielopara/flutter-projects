import 'package:expense_tracker/widgets/expense_list/expenses_list.dart';
import 'package:expense_tracker/model/expense.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
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

  void _addExpense(Expense expense) {
    setState(() {
      _expenseList.add(expense);
    });
  }

  void _removeExpense(Expense expense) {
    setState(() {
      _expenseList.remove(expense);
    });
  }

  void showModal() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return NewExpense(onAddExpense: _addExpense);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No Expenses!',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );

    if (_expenseList.isNotEmpty) {
      content = ExpensesList(
        expenses: _expenseList,
        onRemoveExpense: _removeExpense,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            onPressed: showModal,
            icon: Icon(Icons.add_circle_outline_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          const Text('chart'),
          Expanded(child: content),
        ],
      ),
    );
  }
}
