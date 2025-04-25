import 'package:flutter/material.dart';
import '../models/image_model.dart';
import '../services/gallery_service.dart';

class GalleryProvider extends ChangeNotifier {
  final GalleryService _galleryService = GalleryService();

  List<ImageModel> _images = [];
  List<ImageModel> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  String _currentQuery = '';
  String _selectedCategory = '';

  // Getters
  List<ImageModel> get images => _images;
  List<ImageModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentQuery => _currentQuery;
  String get selectedCategory => _selectedCategory;
  bool get hasApiKey => _galleryService.hasApiKey;

  // Méthode pour définir la clé API
  void setApiKey(String apiKey) {
    _galleryService.setApiKey(apiKey);
    notifyListeners();
  }

  // Méthode pour charger des images aléatoires
  Future<void> loadRandomImages({String category = ''}) async {
    if (!_galleryService.hasApiKey) {
      _error = 'Clé API Pixabay non définie. Veuillez définir une clé API.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _selectedCategory = category;
    notifyListeners();

    try {
      _images = await _galleryService.getRandomImages(
        perPage: 30,
        category: category,
        safeSearch: true,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Méthode pour rechercher des images
  Future<void> searchImages(
    String query, {
    String category = '',
    String colors = '',
    String imageType = 'all',
    String orientation = 'all',
  }) async {
    if (!_galleryService.hasApiKey) {
      _error = 'Clé API Pixabay non définie. Veuillez définir une clé API.';
      notifyListeners();
      return;
    }

    if (query.trim().isEmpty && category.isEmpty && colors.isEmpty) {
      _searchResults = [];
      _currentQuery = '';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _currentQuery = query;
    _selectedCategory = category;
    notifyListeners();

    try {
      _searchResults = await _galleryService.searchImages(
        query,
        perPage: 30,
        category: category,
        colors: colors,
        imageType: imageType,
        orientation: orientation,
        safeSearch: true,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Méthode pour obtenir les détails d'une image
  Future<ImageModel?> getImageDetails(int id) async {
    if (!_galleryService.hasApiKey) {
      _error = 'Clé API Pixabay non définie. Veuillez définir une clé API.';
      notifyListeners();
      return null;
    }

    try {
      return await _galleryService.getImageDetails(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Méthode pour ajouter une image locale
  void addLocalImage(Map<String, dynamic> imageData) {
    final newImage = ImageModel.fromLocal(imageData);
    _images.add(newImage);
    notifyListeners();
  }

  // Méthode pour réinitialiser les résultats de recherche
  void clearSearchResults() {
    _searchResults = [];
    _currentQuery = '';
    notifyListeners();
  }

  // Méthode pour obtenir les catégories disponibles
  List<String> getAvailableCategories() {
    return _galleryService.getAvailableCategories();
  }

  // Méthode pour obtenir les couleurs disponibles
  List<String> getAvailableColors() {
    return _galleryService.getAvailableColors();
  }
}
