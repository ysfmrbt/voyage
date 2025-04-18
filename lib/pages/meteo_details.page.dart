import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/widgets.dart';

class MeteoDetailsPage extends StatelessWidget {
  final String ville;

  const MeteoDetailsPage({super.key, required this.ville});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Vérifier si les données météo sont disponibles
    if (weatherProvider.isLoading) {
      return BasePage(
        title: 'Météo: $ville',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Vérifier s'il y a une erreur
    if (weatherProvider.error != null) {
      return BasePage(
        title: 'Météo: $ville',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                AppText.body(
                  'Erreur lors de la récupération des données météo',
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
        ),
      );
    }

    // Vérifier si les données météo sont disponibles
    if (weatherProvider.currentWeather == null ||
        weatherProvider.dailyForecasts == null) {
      // Essayer de charger les données météo si elles ne sont pas déjà chargées
      if (!weatherProvider.isLoading && weatherProvider.error == null) {
        // Appeler getWeatherForCity avec un délai pour éviter les problèmes de contexte
        Future.microtask(() => weatherProvider.getWeatherForCity(ville));
      }

      return BasePage(
        title: 'Météo: $ville',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Utiliser les données réelles de l'API
    final currentWeather = weatherProvider.currentWeather!;
    final dailyForecasts = weatherProvider.dailyForecasts!;

    // Créer un objet meteoData pour maintenir la compatibilité avec le code existant
    final Map<String, dynamic> meteoData = {
      'temperature': '${currentWeather['temperature'].toStringAsFixed(1)}°C',
      'condition': currentWeather['condition'],
      'humidite': '${currentWeather['humidity']}%',
      'vent': '${currentWeather['wind_speed'].toStringAsFixed(1)} km/h',
      'pression': '${currentWeather['pressure']} hPa',
      'visibilite': '${currentWeather['visibility'].toStringAsFixed(1)} km',
      'lever_soleil': '06:45', // Valeur fictive car non disponible dans l'API
      'coucher_soleil': '20:30', // Valeur fictive car non disponible dans l'API
      'previsions':
          dailyForecasts
              .map(
                (forecast) => {
                  'jour': forecast.date,
                  'temperature_max': '${forecast.maxTemp.toStringAsFixed(1)}°C',
                  'temperature_min': '${forecast.minTemp.toStringAsFixed(1)}°C',
                  'condition': forecast.condition,
                  'icon': forecast.icon,
                },
              )
              .toList(),
    };

    return BasePage(
      title: 'Météo: $ville',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête avec la température actuelle
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDarkMode
                        ? AppTheme.primaryColor.withAlpha(180)
                        : AppTheme.primaryColor,
                    isDarkMode
                        ? AppTheme.primaryColorLight
                        : AppTheme.primaryColorLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ville et date
                  AppText.heading(
                    ville,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppText.body(
                    'Aujourd\'hui',
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Température et icône
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.heading(
                            meteoData['temperature'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppText.body(
                            meteoData['condition'],
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                      Icon(
                        currentWeather['icon'],
                        color: Colors.white,
                        size: 80,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildWeatherDetail(
                            'Humidité',
                            meteoData['humidite'],
                            Icons.water_drop,
                          ),
                        ),
                        Expanded(
                          child: _buildWeatherDetail(
                            'Vent',
                            meteoData['vent'],
                            Icons.air,
                          ),
                        ),
                        Expanded(
                          child: _buildWeatherDetail(
                            'Pression',
                            meteoData['pression'],
                            Icons.speed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Prévisions pour les prochains jours
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AppText.subheading('Prévisions sur 5 jours'),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.secondaryColorLight : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDarkMode ? 40 : 20),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children:
                    meteoData['previsions']
                        .map<Widget>(
                          (prev) => _buildForecastItem(prev, isDarkMode),
                        )
                        .toList(),
              ),
            ),

            // Informations supplémentaires
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppText.subheading('Informations supplémentaires'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Lever du soleil',
                      meteoData['lever_soleil'],
                      Icons.wb_twilight,
                      isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      'Coucher du soleil',
                      meteoData['coucher_soleil'],
                      Icons.nightlight_round,
                      isDarkMode,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Visibilité',
                      meteoData['visibilite'],
                      Icons.visibility,
                      isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      'Indice UV',
                      'Modéré',
                      Icons.wb_sunny_outlined,
                      isDarkMode,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Note sur les données
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppText.caption(
                'Données météorologiques fournies par Open-Meteo.com',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      isDarkMode
                          ? AppTheme.captionColor
                          : AppTheme.captionColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 14),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildForecastItem(Map<String, dynamic> forecast, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppTheme.dividerColor : AppTheme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Jour
          SizedBox(
            width: 90,
            child: AppText.body(
              forecast['jour'],
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          // Icône
          SizedBox(
            width: 40,
            child: Icon(
              forecast['icon'],
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          // Condition (avec Expanded pour éviter les débordements)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AppText.body(
                forecast['condition'],
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          // Températures
          SizedBox(
            width: 100,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: AppText.body(
                    forecast['temperature_max'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: AppText.caption(
                    forecast['temperature_min'],
                    style: TextStyle(
                      color:
                          isDarkMode
                              ? AppTheme.captionColor
                              : AppTheme.captionColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.secondaryColorLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDarkMode ? 40 : 20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 28),
          const SizedBox(height: 8),
          AppText.caption(
            title,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          AppText.body(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
