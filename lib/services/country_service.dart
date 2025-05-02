import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/country_model.dart';
import 'preferences_service.dart';

class CountryService {
  final String baseUrl = 'https://restcountries.com/v2';
  final PreferencesService _preferencesService = PreferencesService();

  // Récupérer tous les pays
  Future<List<CountryModel>> getAllCountries() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/all'));

      if (response.statusCode == 200) {
        // Utiliser utf8.decode pour préserver les caractères spéciaux
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<CountryModel> countries =
            data.map((json) => CountryModel.fromJson(json)).toList();

        // Récupérer la liste des pays exclus
        final excludedCountries =
            await _preferencesService.getExcludedCountries();

        // Filtrer les pays exclus
        if (excludedCountries.isNotEmpty) {
          return countries
              .where(
                (country) =>
                    !excludedCountries.contains(country.alpha2Code) &&
                    !excludedCountries.contains(country.alpha3Code),
              )
              .toList();
        }

        return countries;
      } else {
        throw Exception(
          'Erreur lors de la récupération des pays: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des pays: $e');
    }
  }

  // Récupérer un pays par son code alpha2
  Future<CountryModel> getCountryByCode(String code) async {
    try {
      // Vérifier si le pays est exclu
      final isExcluded = await _preferencesService.isCountryExcluded(code);
      if (isExcluded) {
        throw Exception('Ce pays n\'est pas disponible');
      }

      final response = await http.get(Uri.parse('$baseUrl/alpha/$code'));

      if (response.statusCode == 200) {
        // Utiliser utf8.decode pour préserver les caractères spéciaux
        final dynamic data = json.decode(utf8.decode(response.bodyBytes));
        return CountryModel.fromJson(data);
      } else {
        throw Exception(
          'Erreur lors de la récupération du pays: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du pays: $e');
    }
  }

  // Récupérer les pays par région
  Future<List<CountryModel>> getCountriesByRegion(String region) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/region/$region'));

      if (response.statusCode == 200) {
        // Utiliser utf8.decode pour préserver les caractères spéciaux
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<CountryModel> countries =
            data.map((json) => CountryModel.fromJson(json)).toList();

        // Récupérer la liste des pays exclus
        final excludedCountries =
            await _preferencesService.getExcludedCountries();

        // Filtrer les pays exclus
        if (excludedCountries.isNotEmpty) {
          return countries
              .where(
                (country) =>
                    !excludedCountries.contains(country.alpha2Code) &&
                    !excludedCountries.contains(country.alpha3Code),
              )
              .toList();
        }

        return countries;
      } else {
        throw Exception(
          'Erreur lors de la récupération des pays par région: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des pays par région: $e');
    }
  }

  // Rechercher des pays par nom
  Future<List<CountryModel>> searchCountriesByName(String name) async {
    try {
      // Encoder le nom du pays pour gérer les caractères spéciaux
      final encodedName = Uri.encodeComponent(name);

      final response = await http.get(Uri.parse('$baseUrl/name/$encodedName'));

      if (response.statusCode == 200) {
        // Utiliser utf8.decode pour préserver les caractères spéciaux
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<CountryModel> countries =
            data.map((json) => CountryModel.fromJson(json)).toList();

        // Récupérer la liste des pays exclus
        final excludedCountries =
            await _preferencesService.getExcludedCountries();

        // Filtrer les pays exclus
        if (excludedCountries.isNotEmpty) {
          return countries
              .where(
                (country) =>
                    !excludedCountries.contains(country.alpha2Code) &&
                    !excludedCountries.contains(country.alpha3Code),
              )
              .toList();
        }

        return countries;
      } else if (response.statusCode == 404) {
        // Aucun pays trouvé
        return [];
      } else {
        throw Exception(
          'Erreur lors de la recherche de pays: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de la recherche de pays: $e');
    }
  }
}
