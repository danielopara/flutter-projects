import 'package:flutter/material.dart';
import 'package:weather_app/helper/weather_style.dart';
import 'package:weather_app/model/weather.dart';
import 'package:weather_app/services/weather_services.dart';
import 'dart:async';

import 'package:weather_app/widgets/weather_grid.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<List<List<Weather>>> _weatherFuture;
  String _currentTime = "";
  Timer? _timer;

  void _updateTime() {
    final DateTime now = DateTime.now();

    setState(() {
      _currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => _updateTime(),
    );
    _weatherFuture = WeatherServices().getWeatherDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<Weather>>>(
      future: _weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Check Internet Connection");
        } else {
          final nigeriaWeatherData = snapshot.data![0];
          final abroadWeatherData = snapshot.data![1];

          return SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListTile(
                    leading: const Text(
                      'Nigeria Time:',
                      style: TextStyle(fontSize: 24, color: Colors.white70),
                    ),
                    trailing: Text(
                      _currentTime,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  WeatherGrid(weatherData: nigeriaWeatherData),
                  const SizedBox(height: 20),
                  const Text('Abroad'),
                  WeatherGrid(weatherData: abroadWeatherData),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
