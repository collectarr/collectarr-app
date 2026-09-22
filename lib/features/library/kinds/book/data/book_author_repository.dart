import 'package:collectarr_app/core/api/api_client.dart';

final class BookAuthorRepository {
  const BookAuthorRepository(this._api);

  final ApiClient _api;

  Future<List<BookAuthor>> searchAuthors(
    String query, {
    int limit = 12,
  }) async {
    final rows = await _api.getJsonRows(
      '/api/v1/creators',
      queryParameters: {'q': query, 'limit': limit},
    );
    return rows.map(BookAuthor.fromJson).toList(growable: false);
  }

  Future<List<BookAuthorWorkCredit>> getBookCredits(String authorId) async {
    final rows = await _api.getJsonRows(
      '/api/v1/creators/${Uri.encodeComponent(authorId)}/credits',
    );
    return rows
        .where((row) => row['kind']?.toString() == 'book')
        .map(BookAuthorWorkCredit.fromJson)
        .toList(growable: false);
  }
}

final class BookAuthor {
  const BookAuthor({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory BookAuthor.fromJson(Map<String, dynamic> json) => BookAuthor(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        imageUrl: json['image_url']?.toString(),
      );

  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
}

final class BookAuthorWorkCredit {
  const BookAuthorWorkCredit({
    required this.title,
    required this.role,
    this.coverImageUrl,
  });

  factory BookAuthorWorkCredit.fromJson(Map<String, dynamic> json) =>
      BookAuthorWorkCredit(
        title: json['title']?.toString() ?? 'Untitled',
        role: json['role']?.toString() ?? 'Author',
        coverImageUrl: json['cover_image_url']?.toString(),
      );

  final String title;
  final String role;
  final String? coverImageUrl;
}
