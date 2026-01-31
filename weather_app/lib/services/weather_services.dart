import 'dart:convert';

import 'package:weather_app/model/states.dart';
import 'package:weather_app/model/weather.dart';
import 'package:http/http.dart' as http;

class WeatherServices {
  List<States> nigerianStates = [
    States(name: "Lagos", lon: 3.39, lat: 6.45),
    States(name: "Abuja", lon: 7.39, lat: 9.07),
    States(name: "Port Harcourt", lon: 7.04, lat: 4.81),
    States(name: "Enugu", lon: 7.50, lat: 6.44),
  ];
  Future<Weather> getWeather(String city, double lat, double lon) async {
    final url = Uri.parse(
      "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print(response.body);
        return Weather.fromJson(jsonDecode(response.body), city);
      } else {
        throw Exception("Failed to load weather $city");
      }
    } catch (error) {
      print('Log: $error');
      throw Exception("Failed to connect to Server");
    }
  }

  Future<List<Weather>> getNigerianStates() async {
    return Future.wait(
      nigerianStates.map(
        (state) => getWeather(state.name, state.lat, state.lon),
      ),
    );
  }
}
