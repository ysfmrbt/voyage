import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/image_model.dart';
import '../providers/gallery_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/base_page.dart';
import 'image_details.page.dart';

class GallerySearchPage extends StatefulWidget {
  const GallerySearchPage({Key? key}) : super(key: key);

  @override
  State<GallerySearchPage> createState() => _GallerySearchPageState();
}

class _GallerySearchPageState extends State<GallerySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';
  String _selectedColor = '';
  String _selectedImageType = 'all';

  @override
  void initState() {
    super.initState();
    // Initialiser la page de recherche
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final galleryProvider = Provider.of<GalleryProvider>(
        context,
        listen: false,
      );

      // Définir la clé API si elle n'est pas déjà définie
      if (!galleryProvider.hasApiKey) {
        galleryProvider.setApiKey("49927818-1d764cc34f2360fb9262a94d7");
      }

      // Réinitialiser les résultats de recherche
      galleryProvider.clearSearchResults();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty ||
        _selectedCategory.isNotEmpty ||
        _selectedColor.isNotEmpty) {
      Provider.of<GalleryProvider>(context, listen: false).searchImages(
        query,
        category: _selectedCategory,
        colors: _selectedColor,
        imageType: _selectedImageType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final galleryProvider = Provider.of<GalleryProvider>(context);
    final categories = galleryProvider.getAvailableCategories();
    final colors = galleryProvider.getAvailableColors();

    return BasePage(
      title: "Recherche d'images",
      showBackButton: true,
      showDrawer: false,
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Champ de recherche
                TextField(
                  controller: _searchController,
                  decoration: AppTheme.inputDecoration(
                    "Rechercher",
                    "Entrez un terme de recherche",
                    Icons.search,
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),

                const SizedBox(height: 16),

                // Filtres - Catégorie
                DropdownButtonFormField<String>(
                  decoration: AppTheme.inputDecoration(
                    "Catégorie",
                    "Sélectionner",
                    Icons.category,
                  ),
                  value: _selectedCategory.isEmpty ? null : _selectedCategory,
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Toutes', style: TextStyle(fontSize: 12)),
                    ),
                    ...categories.map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(
                          category.substring(0, 1).toUpperCase() +
                              category.substring(1),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value ?? '';
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Couleur
                DropdownButtonFormField<String>(
                  decoration: AppTheme.inputDecoration(
                    "Couleur",
                    "Sélectionner",
                    Icons.color_lens,
                  ),
                  value: _selectedColor.isEmpty ? null : _selectedColor,
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Toutes', style: TextStyle(fontSize: 12)),
                    ),
                    ...colors.map(
                      (color) => DropdownMenuItem(
                        value: color,
                        child: Text(
                          color.substring(0, 1).toUpperCase() +
                              color.substring(1),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedColor = value ?? '';
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Type d'image
                DropdownButtonFormField<String>(
                  decoration: AppTheme.inputDecoration(
                    "Type d'image",
                    "Sélectionner",
                    Icons.image,
                  ),
                  value: _selectedImageType,
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('Tous', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 'photo',
                      child: Text('Photos', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 'illustration',
                      child: Text(
                        'Illustrations',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'vector',
                      child: Text('Vecteurs', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedImageType = value ?? 'all';
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Bouton de recherche
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _performSearch,
                    icon: const Icon(Icons.search),
                    label: const Text("Rechercher"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Résultats de recherche
          Expanded(child: _buildSearchResults(galleryProvider)),
        ],
      ),
    );
  }

  Widget _buildSearchResults(GalleryProvider galleryProvider) {
    // Afficher un indicateur de chargement
    if (galleryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Afficher un message d'erreur
    if (galleryProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              "Erreur lors de la recherche",
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 8),
            Text(galleryProvider.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    // Afficher les résultats de recherche
    final searchResults = galleryProvider.searchResults;

    if (searchResults.isEmpty) {
      // Si aucun résultat n'est trouvé
      if (galleryProvider.currentQuery.isNotEmpty ||
          _selectedCategory.isNotEmpty ||
          _selectedColor.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text("Aucun résultat trouvé", style: AppTheme.subheadingStyle),
              const SizedBox(height: 8),
              Text(
                "Essayez avec d'autres termes de recherche ou filtres",
                style: TextStyle(color: AppTheme.captionColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      } else {
        // Si aucune recherche n'a été effectuée
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text("Recherchez des images", style: AppTheme.subheadingStyle),
              const SizedBox(height: 8),
              const Text(
                "Utilisez les filtres pour affiner vos résultats",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
    }

    // Afficher les résultats sous forme de grille
    return GridView.builder(
      padding: AppTheme.paddingSmall,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final image = searchResults[index];
        return GestureDetector(
          onTap: () {
            // Naviguer vers la page de détails
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageDetailsPage(image: image),
              ),
            );
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: Image.network(
                      image.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Informations
                Padding(
                  padding: AppTheme.paddingSmall,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      Text(
                        image.title,
                        style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Auteur
                      Text(
                        "Par ${image.author}",
                        style: TextStyle(
                          color: AppTheme.captionColor,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Statistiques
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.remove_red_eye,
                                size: 12,
                                color: AppTheme.captionColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${image.views}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.captionColor,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 12,
                                color: AppTheme.captionColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${image.likes}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.captionColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
