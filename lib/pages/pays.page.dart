import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/base_page.dart';
import '../theme/app_theme.dart';
import '../providers/country_provider.dart';
import '../models/country_model.dart';
import '../widgets/widgets.dart';
import 'country_details.page.dart';

class PaysPage extends StatefulWidget {
  const PaysPage({super.key});

  @override
  State<PaysPage> createState() => _PaysPageState();
}

class _PaysPageState extends State<PaysPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRegion = '';
  final List<String> _regions = [
    'Africa',
    'Americas',
    'Asia',
    'Europe',
    'Oceania',
  ];

  @override
  void initState() {
    super.initState();
    // Charger les pays au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final countryProvider = Provider.of<CountryProvider>(
        context,
        listen: false,
      );

      // Charger d'abord la Tunisie
      countryProvider.loadTunisia();

      // Puis charger tous les pays en arrière-plan
      countryProvider.loadAllCountries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Timer pour éviter de faire trop d'appels API pendant que l'utilisateur tape
  Timer? _debounce;

  void _searchCountries(String query) {
    // Annuler le timer précédent s'il existe
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Si la requête est vide, réinitialiser les filtres immédiatement
    if (query.isEmpty) {
      Provider.of<CountryProvider>(context, listen: false).resetFilters();
      return;
    }

    // Attendre 500ms avant de lancer la recherche
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final countryProvider = Provider.of<CountryProvider>(
        context,
        listen: false,
      );

      // Utiliser la recherche API au lieu du filtrage local
      if (query.length >= 2) {
        countryProvider.searchCountries(query);
      }
    });
  }

  void _selectRegion(String region) {
    setState(() {
      if (_selectedRegion == region) {
        _selectedRegion = '';
        Provider.of<CountryProvider>(context, listen: false).resetFilters();
      } else {
        _selectedRegion = region;
        Provider.of<CountryProvider>(
          context,
          listen: false,
        ).loadCountriesByRegion(region);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final countryProvider = Provider.of<CountryProvider>(context);
    final countries = countryProvider.filteredCountries;

    return BasePage(
      title: "Pays",
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: AppTheme.inputDecoration(
                    "Rechercher",
                    "Entrez un nom de pays",
                    Icons.search,
                  ),
                  onChanged: _searchCountries,
                ),

                const SizedBox(height: 16),

                // Filtres par région
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _regions.map((region) {
                          final isSelected = _selectedRegion == region;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(region),
                              selected: isSelected,
                              onSelected: (_) => _selectRegion(region),
                              backgroundColor: AppTheme.surfaceColor,
                              selectedColor: AppTheme.primaryColor.withAlpha(
                                50,
                              ),
                              checkmarkColor: AppTheme.primaryColor,
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? AppTheme.primaryColor
                                        : AppTheme.textColor,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Bouton pour charger la Tunisie directement
                ElevatedButton.icon(
                  onPressed: () => _navigateToTunisiaDetails(context),
                  icon: const Icon(Icons.flag),
                  label: const Text('Voir la Tunisie'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),

          // Liste des pays
          Expanded(child: _buildCountryList(countryProvider, countries)),
        ],
      ),
    );
  }

  // Méthode pour naviguer vers la page de détails de la Tunisie
  void _navigateToTunisiaDetails(BuildContext context) {
    final countryProvider = Provider.of<CountryProvider>(
      context,
      listen: false,
    );
    if (countryProvider.selectedCountry != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  CountryDetailsPage(country: countryProvider.selectedCountry!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chargement de la Tunisie en cours...')),
      );
      countryProvider.loadTunisia().then((_) {
        if (mounted && countryProvider.selectedCountry != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CountryDetailsPage(
                    country: countryProvider.selectedCountry!,
                  ),
            ),
          );
        }
      });
    }
  }

  Widget _buildCountryList(
    CountryProvider countryProvider,
    List<CountryModel> countries,
  ) {
    if (countryProvider.isLoading && countries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (countryProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              "Erreur lors du chargement des pays",
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 8),
            Text(countryProvider.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                countryProvider.loadAllCountries();
              },
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    if (countries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text("Aucun pays trouvé", style: AppTheme.subheadingStyle),
            const SizedBox(height: 8),
            const Text(
              "Essayez avec d'autres termes de recherche ou filtres",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: countries.length,
      itemBuilder: (context, index) {
        final country = countries[index];
        return Card(
          margin: AppTheme.paddingSmall,
          child: ListTile(
            title: Text(
              country.name,
              style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
            ),
            subtitle: Text(
              country.capital != null
                  ? "Capitale: ${country.capital}"
                  : "Pas de capitale",
              style: TextStyle(color: AppTheme.captionColor),
            ),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(country.flags.png),
              backgroundColor: Colors.transparent,
            ),
            trailing: Icon(Icons.arrow_forward, color: AppTheme.primaryColor),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CountryDetailsPage(country: country),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
