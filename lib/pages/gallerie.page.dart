import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/base_page.dart';
import '../theme/app_theme.dart';
import '../providers/gallery_provider.dart';
import '../models/image_model.dart';
import '../widgets/widgets.dart';
import 'image_details.page.dart';

class GalleriePage extends StatefulWidget {
  const GalleriePage({super.key});

  @override
  State<GalleriePage> createState() => _GalleriePageState();
}

class _GalleriePageState extends State<GalleriePage> {
  @override
  void initState() {
    super.initState();
    // Charger les images aléatoires au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final galleryProvider = Provider.of<GalleryProvider>(
        context,
        listen: false,
      );

      // Définir directement la clé API Pixabay ici
      galleryProvider.setApiKey("49927818-1d764cc34f2360fb9262a94d7");

      // Réinitialiser les résultats de recherche
      galleryProvider.clearSearchResults();

      // Charger les images aléatoires
      galleryProvider.loadRandomImages();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Méthode pour naviguer vers la page de recherche
  void _navigateToSearchPage() {
    Navigator.pushNamed(context, '/gallery_search');
  }

  // Méthode pour rechercher par catégorie
  void _searchByCategory(String category) {
    // Naviguer vers la page de recherche avec la catégorie sélectionnée
    final galleryProvider = Provider.of<GalleryProvider>(
      context,
      listen: false,
    );

    // Réinitialiser les résultats de recherche
    galleryProvider.clearSearchResults();

    // Effectuer la recherche par catégorie
    galleryProvider.searchImages('', category: category);

    // Naviguer vers la page de recherche
    Navigator.pushNamed(context, '/gallery_search');
  }

  @override
  Widget build(BuildContext context) {
    final galleryProvider = Provider.of<GalleryProvider>(context);

    // Déterminer quelles images afficher (résultats de recherche ou images aléatoires)
    final List<ImageModel> displayImages =
        galleryProvider.searchResults.isNotEmpty
            ? galleryProvider.searchResults
            : galleryProvider.images;

    return BasePage(
      title: "Galerie",
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Rechercher des images',
          onPressed: _navigateToSearchPage,
        ),
        PopupMenuButton<String>(
          tooltip: 'Filtrer par catégorie',
          onSelected: (String value) {
            if (value == 'all') {
              // Charger toutes les images
              Provider.of<GalleryProvider>(
                context,
                listen: false,
              ).loadRandomImages();
            } else {
              // Rechercher par catégorie
              _searchByCategory(value);
            }
          },
          itemBuilder: (BuildContext context) {
            final galleryProvider = Provider.of<GalleryProvider>(
              context,
              listen: false,
            );
            final categories = galleryProvider.getAvailableCategories();

            // Créer les éléments du menu
            final items = <PopupMenuItem<String>>[];

            // Ajouter l'option "Tous"
            items.add(const PopupMenuItem(value: "all", child: Text("Tous")));

            // Ajouter les catégories disponibles (limiter à 10 pour éviter un menu trop long)
            for (int i = 0; i < 10 && i < categories.length; i++) {
              final category = categories[i];
              items.add(
                PopupMenuItem(
                  value: category,
                  child: Text(
                    category.substring(0, 1).toUpperCase() +
                        category.substring(1),
                  ),
                ),
              );
            }

            return items;
          },
        ),
      ],
      body: SafeArea(
        child: Column(
          children: [
            // Indicateur de chargement
            if (galleryProvider.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            // Message d'erreur
            else if (galleryProvider.error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Erreur lors du chargement des images",
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(galleryProvider.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          galleryProvider.loadRandomImages();
                        },
                        child: const Text("Réessayer"),
                      ),
                    ],
                  ),
                ),
              )
            // Résultats de recherche ou images aléatoires
            else if (displayImages.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  padding: AppTheme.paddingSmall,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: displayImages.length,
                  itemBuilder: (context, index) {
                    final image = displayImages[index];
                    return GestureDetector(
                      onTap: () {
                        // Naviguer vers la page de détails
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ImageDetailsPage(image: image),
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
                            Expanded(
                              child: Image.network(
                                image.imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: AppTheme.paddingSmall,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    image.title,
                                    style: AppTheme.subheadingStyle.copyWith(
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    image.category,
                                    style: TextStyle(
                                      color: AppTheme.captionColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            // Aucune image trouvée
            else
              const Expanded(
                child: Center(child: Text("Aucune image trouvée")),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ajouter une nouvelle image
          _showAddImageDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddImageDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final urlController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: SingleChildScrollView(
              child: Padding(
                padding: AppTheme.paddingMedium,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Ajouter une nouvelle image",
                      style: AppTheme.headingStyle,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: AppTheme.inputDecoration(
                        "Titre",
                        "Entrez le titre de l'image",
                        Icons.title,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: AppTheme.inputDecoration(
                        "Description",
                        "Entrez la description de l'image",
                        Icons.description,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: urlController,
                      decoration: AppTheme.inputDecoration(
                        "URL de l'image",
                        "Entrez l'URL de l'image",
                        Icons.link,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: categoryController,
                      decoration: AppTheme.inputDecoration(
                        "Catégorie",
                        "Entrez la catégorie de l'image",
                        Icons.category,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Annuler", style: AppTheme.linkTextStyle),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Ajouter l'image si tous les champs sont remplis
                            if (titleController.text.isNotEmpty &&
                                urlController.text.isNotEmpty &&
                                categoryController.text.isNotEmpty) {
                              // Ajouter l'image au provider
                              Provider.of<GalleryProvider>(
                                context,
                                listen: false,
                              ).addLocalImage({
                                'title': titleController.text,
                                'description': descriptionController.text,
                                'imageUrl': urlController.text,
                                'category': categoryController.text,
                              });
                              Navigator.of(context).pop();
                            } else {
                              // Afficher un message d'erreur
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Veuillez remplir tous les champs obligatoires",
                                  ),
                                ),
                              );
                            }
                          },
                          style: AppTheme.primaryButtonStyle,
                          child: const Text("Enregistrer"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
