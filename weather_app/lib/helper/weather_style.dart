import 'package:flutter/material.dart';

class WeatherStyle {
  final IconData iconData;
  final LinearGradient gradient;
  final String label;

  const WeatherStyle({
    required this.iconData,
    required this.gradient,
    required this.label,
  });
}

class WeatherHelper {
  static WeatherStyle getStyle(int code) {
    switch (code) {
      case 0:
        return WeatherStyle(
          iconData: Icons.wb_sunny_rounded,
          label: "Sunny",
          gradient: const LinearGradient(
            colors: [Color(0xFFff9a44), Color(0xFFfc6076)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 1:
      case 2:
      case 3:
        return WeatherStyle(
          iconData: Icons.cloud,
          label: "Cloudy",
          gradient: const LinearGradient(
            colors: [Color(0xFF544a7d), Color(0xFFffd452)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 45:
      case 48: // Fog
        return WeatherStyle(
          iconData: Icons.foggy,
          label: "Foggy",
          gradient: const LinearGradient(
            colors: [Color(0xFF3E5151), Color(0xFFDECBA4)], // Grey/Brown tones
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 51:
      case 53:
      case 55: // Drizzle
      case 61:
      case 63:
      case 65: // Rain
      case 80:
      case 81:
      case 82: // Rain showers
        return WeatherStyle(
          iconData: Icons.water_drop,
          label: "Rainy",
          gradient: const LinearGradient(
            colors: [Color(0xFF005C97), Color(0xFF363795)], // Deep Blues
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 95:
      case 96:
      case 99: // Thunderstorm
        return WeatherStyle(
          iconData: Icons.thunderstorm,
          label: "Stormy",
          gradient: const LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)], // Dark Greys
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      default:
        // Default fallback
        return WeatherStyle(
          iconData: Icons.cloud_outlined,
          label: "Unknown",
          gradient: const LinearGradient(
            colors: [Colors.grey, Colors.blueGrey],
          ),
        );
    }
  }
}
