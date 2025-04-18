import 'package:flutter/material.dart';

class WeatherModel {
  final double latitude;
  final double longitude;
  final String timezone;
  final HourlyUnits hourlyUnits;
  final Hourly hourly;

  WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.hourlyUnits,
    required this.hourly,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      latitude:
          (json['latitude'] is int)
              ? (json['latitude'] as int).toDouble()
              : json['latitude'] as double,
      longitude:
          (json['longitude'] is int)
              ? (json['longitude'] as int).toDouble()
              : json['longitude'] as double,
      timezone: json['timezone'] as String,
      hourlyUnits: HourlyUnits.fromJson(
        json['hourly_units'] as Map<String, dynamic>,
      ),
      hourly: Hourly.fromJson(json['hourly'] as Map<String, dynamic>),
    );
  }
}

class HourlyUnits {
  final String temperature;
  final String apparentTemperature;
  final String precipitationProbability;
  final String precipitation;
  final String weatherCode;
  final String cloudCover;
  final String visibility;
  final String relativeHumidity;
  final String windSpeed;
  final String windDirection;
  final String windGusts;

  HourlyUnits({
    required this.temperature,
    required this.apparentTemperature,
    required this.precipitationProbability,
    required this.precipitation,
    required this.weatherCode,
    required this.cloudCover,
    required this.visibility,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.windDirection,
    required this.windGusts,
  });

  factory HourlyUnits.fromJson(Map<String, dynamic> json) {
    return HourlyUnits(
      temperature: json['temperature_2m'],
      apparentTemperature: json['apparent_temperature'],
      precipitationProbability: json['precipitation_probability'],
      precipitation: json['precipitation'],
      weatherCode: json['weather_code'],
      cloudCover: json['cloud_cover'],
      visibility: json['visibility'],
      relativeHumidity: json['relative_humidity_2m'],
      windSpeed: json['wind_speed_10m'],
      windDirection: json['wind_direction_10m'],
      windGusts: json['wind_gusts_10m'],
    );
  }
}

class Hourly {
  final List<String> time;
  final List<double> temperature;
  final List<double> apparentTemperature;
  final List<int> precipitationProbability;
  final List<double> precipitation;
  final List<int> weatherCode;
  final List<int> cloudCover;
  final List<double> visibility;
  final List<int> relativeHumidity;
  final List<double> windSpeed;
  final List<int> windDirection;
  final List<double> windGusts;

  Hourly({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.precipitationProbability,
    required this.precipitation,
    required this.weatherCode,
    required this.cloudCover,
    required this.visibility,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.windDirection,
    required this.windGusts,
  });

  factory Hourly.fromJson(Map<String, dynamic> json) {
    return Hourly(
      time: List<String>.from(json['time']),
      temperature: _parseDoubleList(json['temperature_2m']),
      apparentTemperature: _parseDoubleList(json['apparent_temperature']),
      precipitationProbability: _parseIntList(
        json['precipitation_probability'],
      ),
      precipitation: _parseDoubleList(json['precipitation']),
      weatherCode: _parseIntList(json['weather_code']),
      cloudCover: _parseIntList(json['cloud_cover']),
      visibility: _parseDoubleList(json['visibility']),
      relativeHumidity: _parseIntList(json['relative_humidity_2m']),
      windSpeed: _parseDoubleList(json['wind_speed_10m']),
      windDirection: _parseIntList(json['wind_direction_10m']),
      windGusts: _parseDoubleList(json['wind_gusts_10m']),
    );
  }

  // Helper method to safely parse a list of doubles
  static List<double> _parseDoubleList(dynamic list) {
    return (list as List).map((item) {
      if (item is int) {
        return item.toDouble();
      } else if (item is double) {
        return item;
      } else {
        return double.parse(item.toString());
      }
    }).toList();
  }

  // Helper method to safely parse a list of integers
  static List<int> _parseIntList(dynamic list) {
    return (list as List).map((item) {
      if (item is int) {
        return item;
      } else if (item is double) {
        return item.round();
      } else {
        return int.parse(item.toString());
      }
    }).toList();
  }
}

// Helper class to get daily forecasts from hourly data
class DailyForecast {
  final String date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final String condition;
  final IconData icon;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.condition,
    required this.icon,
  });
}
