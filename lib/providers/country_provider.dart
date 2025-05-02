import 'package:flutter/material.dart';
import '../models/country_model.dart';
import '../services/country_service.dart';

class CountryProvider extends ChangeNotifier {
  final CountryService _countryService = CountryService();

  List<CountryModel> _countries = [];
  List<CountryModel> _filteredCountries = [];
  CountryModel? _selectedCountry;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedRegion = '';

  // Getters
  List<CountryModel> get countries => _countries;
  List<CountryModel> get filteredCountries =>
      _filteredCountries.isEmpty &&
              _searchQuery.isEmpty &&
              _selectedRegion.isEmpty
          ? _countries
          : _filteredCountries;
  CountryModel? get selectedCountry => _selectedCountry;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedRegion => _selectedRegion;

  // Charger tous les pays
  Future<void> loadAllCountries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _countries = await _countryService.getAllCountries();
      _filteredCountries = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Charger un pays par son code
  Future<void> loadCountryByCode(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedCountry = await _countryService.getCountryByCode(code);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Charger les pays par région
  Future<void> loadCountriesByRegion(String region) async {
    _isLoading = true;
    _error = null;
    _selectedRegion = region;
    notifyListeners();

    try {
      _filteredCountries = await _countryService.getCountriesByRegion(region);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Rechercher des pays par nom
  Future<void> searchCountries(String query) async {
    if (query.isEmpty) {
      _filteredCountries = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _searchQuery = query;
    notifyListeners();

    try {
      // Si la requête contient des caractères spéciaux, essayer d'abord avec la requête normalisée
      if (_containsSpecialChars(query)) {
        try {
          // Essayer d'abord avec la requête originale
          _filteredCountries = await _countryService.searchCountriesByName(
            query,
          );
        } catch (e) {
          // Si ça échoue, essayer avec la requête normalisée
          final normalizedQuery = _normalizeString(query);
          _filteredCountries = await _countryService.searchCountriesByName(
            normalizedQuery,
          );
        }
      } else {
        // Requête sans caractères spéciaux
        _filteredCountries = await _countryService.searchCountriesByName(query);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Vérifier si une chaîne contient des caractères spéciaux
  bool _containsSpecialChars(String input) {
    final specialCharsRegex = RegExp(r'[éèêëàâäîïôöùûüÿçñ]');
    return specialCharsRegex.hasMatch(input);
  }

  // Filtrer les pays localement
  void filterCountriesLocally(String query) {
    if (query.isEmpty) {
      _filteredCountries = [];
      _searchQuery = '';
    } else {
      _searchQuery = query;

      // Normaliser la requête et les noms de pays pour gérer les caractères spéciaux
      final normalizedQuery = _normalizeString(query.toLowerCase());

      _filteredCountries =
          _countries.where((country) {
            final normalizedName = _normalizeString(country.name.toLowerCase());
            return normalizedName.contains(normalizedQuery);
          }).toList();
    }
    notifyListeners();
  }

  // Fonction pour normaliser les chaînes (supprimer les accents et autres caractères spéciaux)
  String _normalizeString(String input) {
    // Convertir les caractères accentués en caractères non accentués
    // Par exemple: é -> e, à -> a, ç -> c, etc.
    return input
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ÿ', 'y')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n');
  }

  // Sélectionner un pays
  void selectCountry(CountryModel country) {
    _selectedCountry = country;
    notifyListeners();
  }

  // Réinitialiser les filtres
  void resetFilters() {
    _filteredCountries = [];
    _searchQuery = '';
    _selectedRegion = '';
    notifyListeners();
  }

  // Charger la Tunisie directement
  Future<void> loadTunisia() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Utiliser le nom du pays sans caractères spéciaux pour éviter les problèmes
      final tunisiaList = await _countryService.searchCountriesByName(
        'tunisia',
      );

      if (tunisiaList.isNotEmpty) {
        _selectedCountry = tunisiaList.first;
        _filteredCountries = tunisiaList;
      } else {
        // Si la première tentative échoue, essayer avec "tunisie"
        final tunisieList = await _countryService.searchCountriesByName(
          'tunisie',
        );

        if (tunisieList.isNotEmpty) {
          _selectedCountry = tunisieList.first;
          _filteredCountries = tunisieList;
        } else {
          _error = 'Pays non trouvé';
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}
