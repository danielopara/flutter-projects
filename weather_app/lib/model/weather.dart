class Weather {
  final String cityName;
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
  });

  factory Weather.fromJson(Map<String, dynamic> json, String name) {
    return Weather(
      cityName: name,
      temperature: json['current']['temperature_2m'].toDouble(),
      condition: _mapConditionCode(json['current']['weather_code']),
      humidity: json['current']['relative_humidity_2m'],
      windSpeed: json['current']['wind_speed_10m'].toDouble(),
    );
  }

  static String _mapConditionCode(int code) {
    if (code == 0) return "Clear Skies";
    if (code <= 3) return "Partly Cloudy";
    if (code >= 51 && code <= 67) return "Rainy / Drizzle";
    if (code >= 95) return "Thunderstorm";
    return "Harmattan / Hazy";
  }
}
