import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _excludedCountriesKey = 'excluded_countries';

  // Récupérer la liste des pays exclus
  Future<List<String>> getExcludedCountries() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_excludedCountriesKey) ?? [];
  }

  // Sauvegarder la liste des pays exclus
  Future<void> saveExcludedCountries(List<String> countries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_excludedCountriesKey, countries);
  }

  // Ajouter un pays à la liste des exclusions
  Future<void> addExcludedCountry(String countryCode) async {
    final excludedCountries = await getExcludedCountries();
    if (!excludedCountries.contains(countryCode)) {
      excludedCountries.add(countryCode);
      await saveExcludedCountries(excludedCountries);
    }
  }

  // Retirer un pays de la liste des exclusions
  Future<void> removeExcludedCountry(String countryCode) async {
    final excludedCountries = await getExcludedCountries();
    if (excludedCountries.contains(countryCode)) {
      excludedCountries.remove(countryCode);
      await saveExcludedCountries(excludedCountries);
    }
  }

  // Vérifier si un pays est exclu
  Future<bool> isCountryExcluded(String countryCode) async {
    final excludedCountries = await getExcludedCountries();
    return excludedCountries.contains(countryCode);
  }
}
