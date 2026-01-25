import 'package:flutter/material.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

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
              child: const Text('BMI History', style: TextStyle(fontSize: 24)),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(children: []),
            ),
          ],
        ),
      ),
    );
  }
}
