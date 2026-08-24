import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';

class ComicRelease {
  const ComicRelease({
    required this.id,
    required this.title,
    this.publisher,
    this.imprint,
    this.isbn,
    this.upc,
    this.releaseDate,
    this.coverImageUrl,
  });

  final String id;
  final String title;
  final String? publisher;
  final String? imprint;
  final String? isbn;
  final String? upc;
  final DateTime? releaseDate;
  final String? coverImageUrl;

  List<dynamic> get variants => const [];

  factory ComicRelease.fromEditionDto(CatalogEditionDto dto) {
    return ComicRelease(
      id: dto.id,
      title: dto.title,
      publisher: dto.publisher,
      imprint: dto.metadata?['imprint'] as String?,
      isbn: dto.isbn,
      upc: dto.upc,
      releaseDate: dto.releaseDate,
      coverImageUrl: dto.metadata?['cover_image_url'] as String?,
    );
  }

  factory ComicRelease.fromJson(Map<String, dynamic> json) {
    return ComicRelease(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      publisher: json['publisher'] as String?,
      imprint: json['imprint'] as String?,
      isbn: json['isbn'] as String?,
      upc: json['upc'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      coverImageUrl: json['cover_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (publisher != null) 'publisher': publisher,
        if (imprint != null) 'imprint': imprint,
        if (isbn != null) 'isbn': isbn,
        if (upc != null) 'upc': upc,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      };
}

