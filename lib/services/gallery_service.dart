import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/image_model.dart';

class GalleryService {
  // Utilisation de l'API Pixabay
  static const String baseUrl = 'https://pixabay.com/api/';

  // La clé API sera fournie par l'utilisateur
  String? _apiKey;

  // Définir la clé API
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  // Vérifier si la clé API est définie
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  // Méthode pour rechercher des images
  Future<List<ImageModel>> searchImages(
    String query, {
    int page = 1,
    int perPage = 20,
    String imageType = 'all',
    String orientation = 'all',
    String category = '',
    String colors = '',
    bool safeSearch = true,
    String order = 'popular',
  }) async {
    if (!hasApiKey) {
      throw Exception(
        'Clé API Pixabay non définie. Veuillez définir une clé API avec setApiKey().',
      );
    }

    try {
      // Construire l'URL avec les paramètres
      final queryParams = {
        'key': _apiKey!,
        'q': query,
        'page': page.toString(),
        'per_page': perPage.toString(),
        'image_type': imageType,
        'orientation': orientation,
        'safesearch': safeSearch.toString(),
        'order': order,
      };

      // Ajouter les paramètres optionnels s'ils sont définis
      if (category.isNotEmpty) queryParams['category'] = category;
      if (colors.isNotEmpty) queryParams['colors'] = colors;

      final url = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('hits')) {
          final List<dynamic> hits = data['hits'];

          // Convertir les données en modèles d'image
          return hits.map((item) => ImageModel.fromPixabay(item)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
          'Erreur lors de la récupération des images: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Méthode pour obtenir des images aléatoires (populaires sans requête)
  Future<List<ImageModel>> getRandomImages({
    int page = 1,
    int perPage = 20,
    String category = '',
    bool safeSearch = true,
  }) async {
    if (!hasApiKey) {
      throw Exception(
        'Clé API Pixabay non définie. Veuillez définir une clé API avec setApiKey().',
      );
    }

    try {
      // Construire l'URL avec les paramètres
      final queryParams = {
        'key': _apiKey!,
        'page': page.toString(),
        'per_page': perPage.toString(),
        'safesearch': safeSearch.toString(),
        'order': 'popular',
      };

      // Ajouter la catégorie si elle est définie
      if (category.isNotEmpty) queryParams['category'] = category;

      final url = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('hits')) {
          final List<dynamic> hits = data['hits'];

          // Convertir les données en modèles d'image
          return hits.map((item) => ImageModel.fromPixabay(item)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
          'Erreur lors de la récupération des images: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Méthode pour obtenir les détails d'une image par son ID
  Future<ImageModel> getImageDetails(int id) async {
    if (!hasApiKey) {
      throw Exception(
        'Clé API Pixabay non définie. Veuillez définir une clé API avec setApiKey().',
      );
    }

    try {
      final url = Uri.parse(
        baseUrl,
      ).replace(queryParameters: {'key': _apiKey!, 'id': id.toString()});

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('hits') && data['hits'].isNotEmpty) {
          return ImageModel.fromPixabay(data['hits'][0]);
        } else {
          throw Exception('Image non trouvée');
        }
      } else {
        throw Exception(
          'Erreur lors de la récupération de l\'image: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Méthode pour obtenir les catégories disponibles
  List<String> getAvailableCategories() {
    return [
      'backgrounds',
      'fashion',
      'nature',
      'science',
      'education',
      'feelings',
      'health',
      'people',
      'religion',
      'places',
      'animals',
      'industry',
      'computer',
      'food',
      'sports',
      'transportation',
      'travel',
      'buildings',
      'business',
      'music',
    ];
  }

  // Méthode pour obtenir les couleurs disponibles
  List<String> getAvailableColors() {
    return [
      'grayscale',
      'transparent',
      'red',
      'orange',
      'yellow',
      'green',
      'turquoise',
      'blue',
      'lilac',
      'pink',
      'white',
      'gray',
      'black',
      'brown',
    ];
  }
}
