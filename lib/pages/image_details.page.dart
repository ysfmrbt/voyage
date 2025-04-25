import 'package:flutter/material.dart';
import '../models/image_model.dart';
import '../theme/app_theme.dart';
import '../widgets/base_page.dart';

class ImageDetailsPage extends StatelessWidget {
  final ImageModel image;

  const ImageDetailsPage({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: image.title,
      showBackButton: true,
      showDrawer: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image principale
            SizedBox(
              width: double.infinity,
              child: Image.network(
                image.largeImageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Informations sur l'image
            Padding(
              padding: AppTheme.paddingMedium,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et description
                  Text(image.title, style: AppTheme.headingStyle),
                  const SizedBox(height: 16),

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        image.tags
                            .split(', ')
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                backgroundColor: AppTheme.primaryColor
                                    .withAlpha(25),
                                labelStyle: TextStyle(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            )
                            .toList(),
                  ),

                  const SizedBox(height: 24),

                  // Statistiques
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        Icons.remove_red_eye,
                        '${image.views}',
                        'Vues',
                      ),
                      _buildStatItem(
                        Icons.download,
                        '${image.downloads}',
                        'Téléchargements',
                      ),
                      _buildStatItem(
                        Icons.favorite,
                        '${image.likes}',
                        'J\'aime',
                      ),
                      _buildStatItem(
                        Icons.comment,
                        '${image.comments}',
                        'Commentaires',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Informations sur l'auteur
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: AppTheme.paddingMedium,
                      child: Row(
                        children: [
                          if (image.authorImageUrl.isNotEmpty)
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                image.authorImageUrl,
                              ),
                              radius: 30,
                            )
                          else
                            CircleAvatar(radius: 30, child: Icon(Icons.person)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Auteur',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.captionColor,
                                  ),
                                ),
                                Text(
                                  image.author,
                                  style: AppTheme.subheadingStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Ouvrir l'URL de l'image dans le navigateur
                            // Vous pouvez utiliser url_launcher package
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Ouverture de l\'image dans le navigateur',
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.open_in_browser),
                          label: Text('Voir sur Pixabay'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Télécharger l'image
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Téléchargement de l\'image'),
                              ),
                            );
                          },
                          icon: Icon(Icons.download),
                          label: Text('Télécharger'),
                        ),
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
  }

  // Méthode pour construire un élément de statistique
  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppTheme.captionColor),
        ),
      ],
    );
  }
}
