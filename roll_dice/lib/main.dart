import 'package:flutter/material.dart';
import 'package:roll_dice/graident_decorator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GraidentDecorator(
          start: const Color.fromARGB(255, 1, 30, 148),
          end: Colors.blue,
        ),
      ),
    );
  }
}
