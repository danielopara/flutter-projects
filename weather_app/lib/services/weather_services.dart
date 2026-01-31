import 'dart:convert';

import 'package:weather_app/model/weather.dart';
import 'package:http/http.dart' as http;

class WeatherServices {
  Future<Weather> getWeather(String city, double lat, double lon) async {
    final url = Uri.https(
      "api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body), city);
      } else {
        throw Exception("Failed to load weather $city");
      }
    } catch (error) {
      print('Log: $error');
      throw Exception("Failed to connect to Server");
    }
  }
}
