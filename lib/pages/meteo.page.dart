import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../widgets/widgets.dart';

class MeteoPage extends StatefulWidget {
  const MeteoPage({super.key});

  @override
  State<MeteoPage> createState() => _MeteoPageState();
}

class _MeteoPageState extends State<MeteoPage> {
  final TextEditingController _villeController = TextEditingController();
  String? _villeRecherchee;

  @override
  void dispose() {
    _villeController.dispose();
    super.dispose();
  }

  void _rechercherVille() {
    final ville = _villeController.text.trim();
    if (ville.isNotEmpty) {
      setState(() {
        _villeRecherchee = ville;
      });
      // Ici, vous pourriez appeler une API météo avec la ville recherchée
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un nom de ville')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
                onSuffixIconPressed: _rechercherVille,
              ),
            ),

            const SizedBox(height: 16),

            // Bouton de recherche
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppButton(
                text: 'Rechercher',
                onPressed: _rechercherVille,
                icon: Icons.search,
              ),
            ),

            const SizedBox(height: 32),

            // Affichage des résultats
            if (_villeRecherchee != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.subheading('Météo pour $_villeRecherchee'),
                      const SizedBox(height: 16),
                      // Ici, vous afficheriez les données météo réelles
                      // Pour l'instant, affichons un message placeholder
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(Icons.cloud, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              AppText.body(
                                'Données météo non disponibles',
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              AppText.caption(
                                'Cette fonctionnalité nécessite une intégration API',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
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
