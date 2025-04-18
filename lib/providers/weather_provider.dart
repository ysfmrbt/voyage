import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/geocoding_model.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  WeatherModel? _weatherData;
  Map<String, dynamic>? _currentWeather;
  List<DailyForecast>? _dailyForecasts;
  String? _cityName;
  bool _isLoading = false;
  String? _error;

  // Recherche de villes
  List<CityLocation> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  // Getters
  WeatherModel? get weatherData => _weatherData;
  Map<String, dynamic>? get currentWeather => _currentWeather;
  List<DailyForecast>? get dailyForecasts => _dailyForecasts;
  String? get cityName => _cityName;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters pour la recherche
  List<CityLocation> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;

  // Méthode pour obtenir les données météo pour une ville
  Future<void> getWeatherForCity(String cityName) async {
    _isLoading = true;
    _error = null;
    _cityName = cityName;
    notifyListeners();

    try {
      // Obtenir les coordonnées de la ville
      final coordinates = await _weatherService.getCityCoordinates(cityName);

      // Obtenir les données météo à partir des coordonnées
      _weatherData = await _weatherService.getWeatherByCoordinates(
        coordinates['latitude']!,
        coordinates['longitude']!,
      );

      // Extraire les données météo actuelles et les prévisions quotidiennes
      _currentWeather = _weatherService.getCurrentWeather(_weatherData!);
      _dailyForecasts = _weatherService.getDailyForecasts(_weatherData!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Méthode pour rechercher des villes
  Future<void> searchCities(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchError = null;
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      final result = await _weatherService.searchCities(query);
      _searchResults = result.results;
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _searchResults = [];
      _isSearching = false;
      _searchError = e.toString();
      notifyListeners();
    }
  }

  // Méthode pour obtenir les données météo pour une ville spécifique par ses coordonnées
  Future<void> getWeatherForLocation(CityLocation location) async {
    _isLoading = true;
    _error = null;
    _cityName = location.displayName;
    notifyListeners();

    try {
      // Obtenir les données météo à partir des coordonnées
      _weatherData = await _weatherService.getWeatherByCoordinates(
        location.latitude,
        location.longitude,
      );

      // Extraire les données météo actuelles et les prévisions quotidiennes
      _currentWeather = _weatherService.getCurrentWeather(_weatherData!);
      _dailyForecasts = _weatherService.getDailyForecasts(_weatherData!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Méthode pour réinitialiser les données
  void reset() {
    _weatherData = null;
    _currentWeather = null;
    _dailyForecasts = null;
    _cityName = null;
    _error = null;
    _searchResults = [];
    _searchError = null;
    notifyListeners();
  }
}
