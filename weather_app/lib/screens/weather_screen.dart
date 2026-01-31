import 'package:flutter/material.dart';
import 'package:weather_app/model/weather.dart';
import 'package:weather_app/services/weather_services.dart';
import 'dart:async';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Weather> _weatherFuture;
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
    _weatherFuture = WeatherServices().getWeather("Lagos", 6.45, 3.39);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Check Internet Connection");
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentTime,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  snapshot.data!.cityName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${snapshot.data!.temperature}°C",
                  style: TextStyle(fontSize: 80, color: Colors.white),
                ),
                Text(
                  "Sunny",
                  style: TextStyle(fontSize: 20, color: Colors.white70),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
