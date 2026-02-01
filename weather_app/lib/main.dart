import 'package:flutter/material.dart';
import 'package:weather_app/screens/weather_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1C1E),
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NIGERIA WEATHER',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add_circle_outline_rounded),
            style: IconButton.styleFrom(iconSize: 32),
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const WeatherScreen(),
    );
  }
}
