import 'package:flutter/material.dart';

class Calculator extends StatefulWidget {
  const Calculator({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });
  final bool isDarkMode;
  final void Function() onThemeToggle;

  @override
  State<StatefulWidget> createState() {
    return _CalculatorState();
  }
}

class _CalculatorState extends State<Calculator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("BMI Calculator")),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              // decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: ListTile(
                title: const Text(
                  'BMI History',
                  style: TextStyle(fontSize: 24),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),

            Divider(),
            Padding(
              padding: EdgeInsets.all(16),
              child: ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: widget.isDarkMode,
                  onChanged: (value) {
                    widget.onThemeToggle();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
