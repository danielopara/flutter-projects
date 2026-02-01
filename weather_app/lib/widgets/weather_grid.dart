import 'package:flutter/material.dart';
import 'package:weather_app/model/weather.dart';
import 'package:weather_app/helper/weather_style.dart';

class WeatherGrid extends StatelessWidget {
  const WeatherGrid({super.key, required this.weatherData});

  final List<Weather> weatherData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
          final weatherStyle = WeatherHelper.getStyle(cityWeather.weatherCode);

          return Container(
            padding: EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              gradient: weatherStyle.gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: weatherStyle.gradient.colors.first.withValues(
                    alpha: 0.8,
                  ),
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
          );
        },
      ),
    );
  }
}
