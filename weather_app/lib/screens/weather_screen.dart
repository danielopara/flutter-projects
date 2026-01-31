import 'package:flutter/material.dart';
import 'package:weather_app/helper/weather_style.dart';
import 'package:weather_app/model/weather.dart';
import 'package:weather_app/services/weather_services.dart';
import 'dart:async';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<List<Weather>> _weatherFuture;
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
    _weatherFuture = WeatherServices().getNigerianStates();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Weather>>(
      future: _weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Check Internet Connection");
        } else {
          final weatherData = snapshot.data!;

          return Center(
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GridView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 30,
                      ),
                      itemCount: weatherData.length,
                      itemBuilder: (context, index) {
                        final cityWeather = weatherData[index];
                        final weatherStyle = WeatherHelper.getStyle(
                          cityWeather.weatherCode,
                        );

                        return Container(
                          padding: EdgeInsets.only(left: 5),
                          decoration: BoxDecoration(
                            gradient: weatherStyle.gradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: weatherStyle.gradient.colors.first
                                    .withValues(alpha: 0.8),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cityWeather.cityName.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "${cityWeather.temperature.toStringAsFixed(0)}°",
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      weatherStyle.label,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Icon(
                                  weatherStyle.iconData,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 35,
                                ),
                              ),
                            ],
                          ),
                          // Column(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Text(
                          //       cityWeather.cityName,
                          //       style: TextStyle(
                          //         fontSize: 24,
                          //         color: Colors.white,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //     Text(
                          //       "${cityWeather.temperature}°C",
                          //       style: TextStyle(
                          //         fontSize: 24,
                          //         color: Colors.white,
                          //       ),
                          //     ),
                          //     Text(
                          //       "Sunny",
                          //       style: TextStyle(
                          //         fontSize: 20,
                          //         color: Colors.white70,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
