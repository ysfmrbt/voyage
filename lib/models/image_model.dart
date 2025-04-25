class ImageModel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String previewUrl;
  final String largeImageUrl;
  final String pageUrl;
  final String category;
  final String tags;
  final int views;
  final int downloads;
  final int likes;
  final int comments;
  final String author;
  final String authorImageUrl;
  final int authorId;

  ImageModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.previewUrl,
    required this.largeImageUrl,
    required this.pageUrl,
    required this.category,
    required this.tags,
    required this.views,
    required this.downloads,
    required this.likes,
    required this.comments,
    required this.author,
    required this.authorImageUrl,
    required this.authorId,
  });

  // Constructeur pour l'API Pixabay
  factory ImageModel.fromPixabay(Map<String, dynamic> json) {
    // Extraire la première catégorie des tags
    final tagsList = (json['tags'] as String).split(', ');
    final firstTag = tagsList.isNotEmpty ? tagsList[0] : 'Divers';

    return ImageModel(
      id: json['id'] ?? 0,
      title: firstTag.capitalize(),
      description: json['tags'] ?? 'Aucune description',
      imageUrl: json['webformatURL'] ?? '',
      previewUrl: json['previewURL'] ?? '',
      largeImageUrl: json['largeImageURL'] ?? '',
      pageUrl: json['pageURL'] ?? '',
      category: firstTag.capitalize(),
      tags: json['tags'] ?? '',
      views: json['views'] ?? 0,
      downloads: json['downloads'] ?? 0,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      author: json['user'] ?? 'Inconnu',
      authorImageUrl: json['userImageURL'] ?? '',
      authorId: json['user_id'] ?? 0,
    );
  }

  // Pour les images locales (exemple)
  factory ImageModel.fromLocal(Map<String, dynamic> data) {
    return ImageModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: data['title'] ?? 'Sans titre',
      description: data['description'] ?? 'Aucune description',
      imageUrl: data['imageUrl'] ?? '',
      previewUrl: data['imageUrl'] ?? '',
      largeImageUrl: data['imageUrl'] ?? '',
      pageUrl: '',
      category: data['category'] ?? 'Divers',
      tags: data['category'] ?? 'Divers',
      views: 0,
      downloads: 0,
      likes: 0,
      comments: 0,
      author: 'Vous',
      authorImageUrl: '',
      authorId: 0,
    );
  }
}

// Extension pour capitaliser la première lettre d'une chaîne
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + this.substring(1);
  }
}
