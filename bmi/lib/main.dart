import 'package:bmi/screens/calculator.dart';
import 'package:flutter/material.dart';

final darkTheme = ThemeData.dark().copyWith(
  primaryColor: Color(0xFF0A0E21),
  scaffoldBackgroundColor: Color(0xFF0A0E21),
  cardColor: Color(0xFF1D1E33),
  appBarTheme: AppBarTheme(backgroundColor: Color(0xFF0A0E21)),
);

final lightTheme = ThemeData.light().copyWith(
  primaryColor: Color(0xFFF0F2F5),
  scaffoldBackgroundColor: Color(0xFFF0F2F5),
  cardColor: Color(0xFFFFFFFF),
  appBarTheme: AppBarTheme(backgroundColor: Color(0xFFF0F2F5)),
);
bool isDarkMode = true;
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isToggle = true;

  void _switchTheme() {
    setState(() {
      _isToggle = !_isToggle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? darkTheme : lightTheme,
      home: Calculator(),
    );
  }
}
