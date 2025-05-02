import 'package:flutter/material.dart';
import '../models/country_model.dart';
import '../services/country_service.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';
import '../widgets/base_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final CountryService _countryService = CountryService();
  final PreferencesService _preferencesService = PreferencesService();
  List<CountryModel> _allCountries = [];
  List<String> _excludedCountries = [];
  bool _isLoading = true;
  String _searchQuery = '';
  List<CountryModel> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Charger tous les pays sans filtrage
      final response = await _countryService.getAllCountries();
      _allCountries = response;

      // Charger les pays exclus
      _excludedCountries = await _preferencesService.getExcludedCountries();

      // Filtrer les pays selon la recherche
      _filterCountries();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterCountries() {
    if (_searchQuery.isEmpty) {
      _filteredCountries = List.from(_allCountries);
    } else {
      _filteredCountries =
          _allCountries
              .where(
                (country) =>
                    country.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    (country.nativeName?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();
    }
  }

  Future<void> _toggleCountryExclusion(CountryModel country) async {
    final alpha2Code = country.alpha2Code;
    final isExcluded = _excludedCountries.contains(alpha2Code);

    setState(() {
      if (isExcluded) {
        _excludedCountries.remove(alpha2Code);
      } else {
        _excludedCountries.add(alpha2Code);
      }
    });

    // Mettre à jour les préférences
    if (isExcluded) {
      await _preferencesService.removeExcludedCountry(alpha2Code);
    } else {
      await _preferencesService.addExcludedCountry(alpha2Code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Paramètres',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Rechercher un pays',
                hintText: 'Entrez le nom d\'un pays',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterCountries();
                });
              },
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredCountries.isEmpty
                    ? const Center(child: Text('Aucun pays trouvé'))
                    : ListView.builder(
                      itemCount: _filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = _filteredCountries[index];
                        final isExcluded = _excludedCountries.contains(
                          country.alpha2Code,
                        );

                        return ListTile(
                          leading:
                              country.flags.png.isNotEmpty
                                  ? Image.network(
                                    country.flags.png,
                                    width: 40,
                                    height: 30,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.flag);
                                    },
                                  )
                                  : const Icon(Icons.flag),
                          title: Text(country.name),
                          subtitle: Text(country.nativeName ?? ''),
                          trailing: Switch(
                            value: !isExcluded,
                            onChanged: (value) {
                              _toggleCountryExclusion(country);
                            },
                          ),
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Capturer le contexte avant l'opération asynchrone
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    // Exclure Israël (code IL)
                    await _preferencesService.addExcludedCountry('IL');

                    // Recharger les données
                    await _loadData();

                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Préférences mises à jour'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('Masquer Israël'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Activez ou désactivez les pays que vous souhaitez voir dans l\'application.',
                  style: AppTheme.captionStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
