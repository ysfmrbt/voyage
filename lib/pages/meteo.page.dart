import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/weather_provider.dart';
import '../models/geocoding_model.dart';
import '../widgets/widgets.dart';
import 'meteo_details.page.dart';

class MeteoPage extends StatefulWidget {
  const MeteoPage({super.key});

  @override
  State<MeteoPage> createState() => _MeteoPageState();
}

class _MeteoPageState extends State<MeteoPage> {
  final TextEditingController _villeController = TextEditingController();

  // Debounce pour la recherche
  DateTime _lastSearchTime = DateTime.now();
  static const _searchDelay = Duration(milliseconds: 500);

  @override
  void dispose() {
    _villeController.dispose();
    super.dispose();
  }

  // Méthode pour rechercher des villes avec debounce
  void _rechercherVilles(String query) async {
    final now = DateTime.now();
    if (now.difference(_lastSearchTime) < _searchDelay) {
      return;
    }
    _lastSearchTime = now;

    if (query.trim().isNotEmpty) {
      // Réinitialiser les données météo pour éviter la confusion
      final weatherProvider = Provider.of<WeatherProvider>(
        context,
        listen: false,
      );

      // Réinitialiser les données météo actuelles pour ne pas les afficher pendant la recherche
      if (weatherProvider.currentWeather != null) {
        weatherProvider.reset();
      }

      // Rechercher les villes
      await weatherProvider.searchCities(query);
    }
  }

  // Méthode pour sélectionner une ville et afficher ses détails météo
  void _selectionnerVille(CityLocation ville) async {
    try {
      // Obtenir les données météo via le provider
      final weatherProvider = Provider.of<WeatherProvider>(
        context,
        listen: false,
      );

      // Afficher un indicateur de chargement immédiatement
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Text('Chargement des données météo...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Effacer les résultats de recherche pour ne pas les afficher pendant le chargement
      weatherProvider.reset();

      // Charger les données météo
      await weatherProvider.getWeatherForLocation(ville);

      // Vérifier si le widget est toujours monté avant d'utiliser le contexte
      if (!mounted) return;

      // Naviguer vers la page de détails météo si aucune erreur
      if (weatherProvider.error == null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeteoDetailsPage(ville: ville.displayName),
          ),
        );
      } else {
        // En cas d'erreur, restaurer les résultats de recherche
        await weatherProvider.searchCities(_villeController.text);

        // Vérifier si le widget est toujours monté avant d'utiliser le contexte
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${weatherProvider.error}')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur inattendue: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return BasePage(
      title: 'Météo',
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête avec fond coloré
            Container(
              color: AppTheme.primaryColorLight,
              padding: AppTheme.paddingLarge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText.heading('Prévisions météo'),
                  const SizedBox(height: 8),
                  AppText.body(
                    'Consultez la météo de votre ville',
                    style: TextStyle(
                      color:
                          isDarkMode
                              ? AppTheme.textColor
                              : AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Formulaire de recherche
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppInputField(
                label: 'Ville',
                hint: 'Entrez le nom d\'une ville',
                controller: _villeController,
                prefixIcon: Icons.location_city,
                suffixIcon: Icons.search,
                onChanged: _rechercherVilles,
                onSuffixIconPressed:
                    () => _rechercherVilles(_villeController.text),
              ),
            ),

            const SizedBox(height: 16),

            // Résultats de recherche
            if (weatherProvider.isSearching)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (weatherProvider.searchError != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text('Erreur: ${weatherProvider.searchError}'),
                ),
              )
            else if (weatherProvider.searchResults.isNotEmpty &&
                _villeController.text.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: AppText.subheading('Résultats de recherche'),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isDarkMode ? AppTheme.surfaceColor : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: weatherProvider.searchResults.length,
                        separatorBuilder:
                            (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final city = weatherProvider.searchResults[index];
                          return ListTile(
                            title: Text(city.name),
                            subtitle: Text(
                              [city.admin1, city.country]
                                  .where((e) => e != null && e.isNotEmpty)
                                  .join(', '),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () => _selectionnerVille(city),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Affichage des résultats
            if (weatherProvider.currentWeather != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.subheading(
                        'Météo pour ${weatherProvider.cityName ?? ""}',
                      ),
                      const SizedBox(height: 16),
                      // Afficher les données météo ou un indicateur de chargement
                      Column(
                        children: [
                          if (weatherProvider.isLoading)
                            const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (weatherProvider.error != null)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 16),
                                    AppText.body(
                                      'Erreur lors de la récupération des données',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    AppText.caption(
                                      weatherProvider.error!,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (weatherProvider.currentWeather != null)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      weatherProvider.currentWeather!['icon'],
                                      size: 64,
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(height: 16),
                                    AppText.heading(
                                      '${weatherProvider.currentWeather!['temperature'].toStringAsFixed(1)}°C',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    AppText.body(
                                      weatherProvider
                                          .currentWeather!['condition'],
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.cloud,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    AppText.body(
                                      'Données météo non disponibles',
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 8),
                                    AppText.caption(
                                      'Recherchez une ville pour voir les prévisions',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (!weatherProvider.isLoading)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: AppButton(
                                text: 'Voir les détails',
                                icon: Icons.visibility,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => MeteoDetailsPage(
                                            ville: weatherProvider.cityName!,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Message quand aucune ville n'est recherchée
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: AppEmptyState(
                    title: 'Aucune ville recherchée',
                    message:
                        'Entrez le nom d\'une ville et appuyez sur Rechercher pour voir les prévisions météo',
                    icon: Icons.wb_sunny,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
