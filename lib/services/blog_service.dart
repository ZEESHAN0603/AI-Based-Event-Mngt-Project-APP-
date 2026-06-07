import 'dart:convert';
import 'api_client.dart';

/// Model for a single news/blog article returned by GET /blogs
class BlogArticle {
  final String title;
  final String? description;
  final String? imageUrl;
  final String? source;
  final String? publishedAt;
  final String url;

  const BlogArticle({
    required this.title,
    this.description,
    this.imageUrl,
    this.source,
    this.publishedAt,
    required this.url,
  });

  factory BlogArticle.fromJson(Map<String, dynamic> json) {
    return BlogArticle(
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      source: json['source'] as String?,
      publishedAt: json['published_at'] as String?,
      url: json['url'] as String? ?? '',
    );
  }
}

class BlogService {
  /// Fetch event-related articles from the backend.
  /// [category] is one of: wedding, birthday, corporate, catering, decoration, events.
  static Future<List<BlogArticle>> getBlogs({String? category}) async {
    final path = category != null && category.isNotEmpty
        ? '/blogs?category=${Uri.encodeComponent(category)}'
        : '/blogs';

    final response = await ApiClient.get(path);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .whereType<Map<String, dynamic>>()
          .map(BlogArticle.fromJson)
          .toList();
    }
    // Surface error message from backend if possible
    try {
      final body = jsonDecode(response.body);
      throw Exception(body['detail'] ?? 'Failed to load blogs');
    } catch (_) {
      throw Exception('Failed to load blogs (${response.statusCode})');
    }
  }
}
