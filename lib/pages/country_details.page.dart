import 'package:flutter/material.dart';
import '../models/country_model.dart';
import '../theme/app_theme.dart';
import '../widgets/base_page.dart';
import '../widgets/widgets.dart';
import 'map.page.dart';

class CountryDetailsPage extends StatelessWidget {
  final CountryModel country;

  const CountryDetailsPage({Key? key, required this.country}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: country.name,
      showBackButton: true,
      showDrawer: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drapeau et informations de base
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drapeau
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(country.flags.png),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Informations de base
                  Padding(
                    padding: AppTheme.paddingMedium,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(country.name, style: AppTheme.headingStyle),
                        const SizedBox(height: 8),
                        Text(
                          'Capitale: ${country.capital}',
                          style: AppTheme.bodyTextStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Région: ${country.region} (${country.subregion})',
                          style: AppTheme.bodyTextStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Population: ${country.population.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')}',
                          style: AppTheme.bodyTextStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Informations détaillées
            AppContainer(
              title: 'Informations détaillées',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Nom natif', country.nativeName),
                  _buildInfoRow('Code alpha-2', country.alpha2Code),
                  _buildInfoRow('Code alpha-3', country.alpha3Code),
                  country.callingCodes.isNotEmpty
                      ? _buildInfoRow(
                        'Indicatif téléphonique',
                        '+${country.callingCodes.first}',
                      )
                      : const SizedBox.shrink(),
                  country.topLevelDomain.isNotEmpty
                      ? _buildInfoRow(
                        'Domaine de premier niveau',
                        country.topLevelDomain.join(', '),
                      )
                      : const SizedBox.shrink(),
                  country.area != null
                      ? _buildInfoRow(
                        'Superficie',
                        '${country.area.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} km²',
                      )
                      : const SizedBox.shrink(),
                  if (country.gini != null)
                    _buildInfoRow('Indice de Gini', '${country.gini}'),
                  country.timezones.isNotEmpty
                      ? _buildInfoRow(
                        'Fuseau horaire',
                        country.timezones.join(', '),
                      )
                      : const SizedBox.shrink(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Monnaies
            AppContainer(
              title: 'Monnaies',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    country.currencies.map((currency) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${currency.name} (${currency.code}) - ${currency.symbol}',
                                style: AppTheme.bodyTextStyle,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Langues
            AppContainer(
              title: 'Langues',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    country.languages.map((language) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.language, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${language.name} (${language.nativeName})',
                                style: AppTheme.bodyTextStyle,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Pays frontaliers
            if (country.borders.isNotEmpty)
              AppContainer(
                title: 'Pays frontaliers',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      country.borders.map((border) {
                        return Chip(
                          label: Text(border),
                          backgroundColor: AppTheme.primaryColor.withAlpha(25),
                          labelStyle: TextStyle(color: AppTheme.primaryColor),
                        );
                      }).toList(),
                ),
              ),

            const SizedBox(height: 16),

            // Organisations régionales
            if (country.regionalBlocs.isNotEmpty)
              AppContainer(
                title: 'Organisations régionales',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      country.regionalBlocs.map((bloc) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.group, color: AppTheme.primaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${bloc.name} (${bloc.acronym})',
                                  style: AppTheme.bodyTextStyle,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),

            const SizedBox(height: 24),

            // Bouton pour voir sur la carte
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Naviguer vers la page de carte
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapPage(country: country),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text('Voir sur la carte'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.captionColor,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTheme.bodyTextStyle)),
        ],
      ),
    );
  }
}
