import 'package:flutter/material.dart';
import 'package:weather_app/screens/weather_screen.dart';

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(title: const Text('Weather App')),
      body: WeatherScreen(),
    );
  }
}
