import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/geocoding_model.dart';

class WeatherService {
  static const String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  // Méthode pour obtenir les données météo à partir des coordonnées
  Future<WeatherModel> getWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    final url = Uri.parse(
      '$baseUrl?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,apparent_temperature,precipitation_probability,precipitation,weather_code,cloud_cover,visibility,relative_humidity_2m,wind_speed_10m,wind_direction_10m,wind_gusts_10m&timezone=auto',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception(
          'Erreur lors de la récupération des données météo: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Méthode pour obtenir les prévisions quotidiennes à partir des données horaires
  List<DailyForecast> getDailyForecasts(WeatherModel weatherData) {
    final List<DailyForecast> dailyForecasts = [];
    final Map<String, List<int>> dailyData = {};

    // Regrouper les données par jour
    for (int i = 0; i < weatherData.hourly.time.length; i++) {
      final String dateTime = weatherData.hourly.time[i];
      final String date =
          dateTime.split('T')[0]; // Extraire la date (YYYY-MM-DD)

      if (!dailyData.containsKey(date)) {
        dailyData[date] = [];
      }

      dailyData[date]!.add(i);
    }

    // Créer les prévisions quotidiennes
    dailyData.forEach((date, indices) {
      // Calculer les températures min et max pour la journée
      double maxTemp = -100;
      double minTemp = 100;
      Map<int, int> weatherCodeCounts = {};

      for (int index in indices) {
        final temp = weatherData.hourly.temperature[index];
        if (temp > maxTemp) maxTemp = temp;
        if (temp < minTemp) minTemp = temp;

        // Compter les occurrences de chaque code météo
        final weatherCode = weatherData.hourly.weatherCode[index];
        weatherCodeCounts[weatherCode] =
            (weatherCodeCounts[weatherCode] ?? 0) + 1;
      }

      // Trouver le code météo le plus fréquent pour la journée
      int mostFrequentWeatherCode = 0;
      int maxCount = 0;

      weatherCodeCounts.forEach((code, count) {
        if (count > maxCount) {
          maxCount = count;
          mostFrequentWeatherCode = code;
        }
      });

      // Convertir la date au format lisible
      final DateTime dateTime = DateTime.parse(date);
      final String formattedDate = _getFormattedDay(dateTime);

      // Créer la prévision quotidienne
      dailyForecasts.add(
        DailyForecast(
          date: formattedDate,
          maxTemp: maxTemp,
          minTemp: minTemp,
          weatherCode: mostFrequentWeatherCode,
          condition: _getWeatherCondition(mostFrequentWeatherCode),
          icon: _getWeatherIcon(mostFrequentWeatherCode),
        ),
      );
    });

    return dailyForecasts;
  }

  // Méthode pour obtenir les données météo actuelles
  Map<String, dynamic> getCurrentWeather(WeatherModel weatherData) {
    // Trouver l'index de l'heure actuelle ou la plus proche
    final now = DateTime.now();
    int closestIndex = 0;
    DateTime closestTime = DateTime.parse(weatherData.hourly.time[0]);
    int minDifference = (now.difference(closestTime).inMinutes).abs();

    for (int i = 1; i < weatherData.hourly.time.length; i++) {
      final time = DateTime.parse(weatherData.hourly.time[i]);
      final difference = (now.difference(time).inMinutes).abs();

      if (difference < minDifference) {
        minDifference = difference;
        closestIndex = i;
        closestTime = time;
      }
    }

    // Extraire les données actuelles
    return {
      'temperature': weatherData.hourly.temperature[closestIndex],
      'condition': _getWeatherCondition(
        weatherData.hourly.weatherCode[closestIndex],
      ),
      'icon': _getWeatherIcon(weatherData.hourly.weatherCode[closestIndex]),
      'humidity': weatherData.hourly.relativeHumidity[closestIndex],
      'wind_speed': weatherData.hourly.windSpeed[closestIndex],
      'pressure': 1015, // Valeur fictive car non disponible dans l'API
      'visibility':
          weatherData.hourly.visibility[closestIndex] / 1000, // Convertir en km
      'precipitation': weatherData.hourly.precipitation[closestIndex],
      'precipitation_probability':
          weatherData.hourly.precipitationProbability[closestIndex],
    };
  }

  // Méthode pour obtenir le jour formaté
  String _getFormattedDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return "Aujourd'hui";
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return "Demain";
    } else {
      return _getDayName(date.weekday);
    }
  }

  // Méthode pour obtenir le nom du jour
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Lundi";
      case 2:
        return "Mardi";
      case 3:
        return "Mercredi";
      case 4:
        return "Jeudi";
      case 5:
        return "Vendredi";
      case 6:
        return "Samedi";
      case 7:
        return "Dimanche";
      default:
        return "";
    }
  }

  // Méthode pour obtenir la condition météo à partir du code WMO
  String _getWeatherCondition(int code) {
    switch (code) {
      case 0:
        return "Ensoleillé";
      case 1:
        return "Principalement ensoleillé";
      case 2:
        return "Partiellement nuageux";
      case 3:
        return "Nuageux";
      case 45:
      case 48:
        return "Brouillard";
      case 51:
      case 53:
      case 55:
        return "Bruine légère";
      case 56:
      case 57:
        return "Bruine verglaçante";
      case 61:
      case 63:
      case 65:
        return "Pluvieux";
      case 66:
      case 67:
        return "Pluie verglaçante";
      case 71:
      case 73:
      case 75:
        return "Neigeux";
      case 77:
        return "Grains de neige";
      case 80:
      case 81:
      case 82:
        return "Averses";
      case 85:
      case 86:
        return "Averses de neige";
      case 95:
        return "Orageux";
      case 96:
      case 99:
        return "Orage avec grêle";
      default:
        return "Inconnu";
    }
  }

  // Méthode pour obtenir l'icône météo à partir du code WMO
  IconData _getWeatherIcon(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny;
      case 1:
        return Icons.wb_sunny;
      case 2:
        return Icons.wb_cloudy;
      case 3:
        return Icons.cloud;
      case 45:
      case 48:
        return Icons.foggy;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return Icons.grain;
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return Icons.water_drop;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return Icons.ac_unit;
      case 80:
      case 81:
      case 82:
        return Icons.beach_access;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm;
      default:
        return Icons.question_mark;
    }
  }

  // Méthode pour rechercher des villes par nom
  Future<GeocodingResult> searchCities(String cityName) async {
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$cityName&count=10&language=fr&format=json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return GeocodingResult.fromJson(data);
      } else {
        throw Exception(
          'Erreur lors de la recherche de villes: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Méthode pour obtenir les coordonnées d'une ville à partir de l'API de géocodage
  Future<Map<String, double>> getCityCoordinates(String cityName) async {
    try {
      final result = await searchCities(cityName);

      if (result.results.isNotEmpty) {
        final city = result.results.first;
        return {'latitude': city.latitude, 'longitude': city.longitude};
      } else {
        throw Exception('Aucune ville trouvée pour "$cityName"');
      }
    } catch (e) {
      throw Exception('Erreur lors de la recherche des coordonnées: $e');
    }
  }
}
