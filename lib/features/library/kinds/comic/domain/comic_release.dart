import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_variant_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';

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
    this.variants = const <CatalogVariantDto>[],
  });

  final String id;
  final String title;
  final String? publisher;
  final String? imprint;
  final String? isbn;
  final String? upc;
  final DateTime? releaseDate;
  final String? coverImageUrl;
  final List<CatalogVariantDto> variants;

  ComicReleaseId get typedId => ComicReleaseId(id);

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
      variants: dto.variants,
    );
  }

  factory ComicRelease.fromJson(Map<String, dynamic> json) {
    final rawVariants = (json['variants'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(CatalogVariantDto.fromJson)
            .toList(growable: false) ??
        const <CatalogVariantDto>[];
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
      variants: rawVariants,
    );
  }

  CatalogEditionDto toEditionDto() {
    return CatalogEditionDto(
      id: id,
      title: title,
      publisher: publisher,
      isbn: isbn,
      upc: upc,
      releaseDate: releaseDate,
      variants: variants,
      metadata: {
        if (imprint != null) 'imprint': imprint,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      },
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
        if (variants.isNotEmpty)
          'variants': variants.map((v) => v.toJson()).toList(),
      };
}
