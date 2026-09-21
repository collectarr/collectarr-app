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
    final rawVariants = [
      for (final entry in json['variants'] is Iterable
          ? json['variants'] as Iterable
          : const <dynamic>[])
        if (entry is Map)
          if (_canonicalVariantFromJson(Map<String, dynamic>.from(entry))
              case final variant?)
            variant,
    ];
    return ComicRelease(
      id: _textValue(json['id']) ?? '',
      title: _textValue(json['title'] ?? json['display_title']) ??
          (_textValue(json['issue_number']) == null
              ? 'Untitled issue'
              : 'Issue ${_textValue(json['issue_number'])}'),
      publisher: _textValue(json['publisher']),
      imprint: _textValue(json['imprint']),
      isbn: _textValue(json['isbn']),
      upc: _textValue(json['upc'] ?? json['barcode']),
      releaseDate: _dateValue(json['release_date'] ?? json['publication_date']),
      coverImageUrl: _textValue(json['cover_image_url']),
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

CatalogVariantDto? _canonicalVariantFromJson(Map<String, dynamic> json) {
  final id = _textValue(json['id']);
  if (id == null) return null;

  final name = _textValue(
        json['name'] ??
            json['variant_name'] ??
            json['cover_label'] ??
            json['variant_type'],
      ) ??
      'Variant';
  final metadata = <String, dynamic>{};
  final rawMetadata = json['metadata'];
  if (rawMetadata is Map) {
    metadata.addAll(Map<String, dynamic>.from(rawMetadata));
  }
  metadata.addAll({
    if (json['cover_label'] != null) 'cover_label': json['cover_label'],
    if (json['printing_number'] != null)
      'printing_number': json['printing_number'],
    if (json['publication_date'] != null)
      'publication_date': json['publication_date'],
    if (json['release_date'] != null) 'release_date': json['release_date'],
    if (json['language'] != null) 'language': json['language'],
    if (json['region'] != null) 'region': json['region'],
    if (json['catalog_number'] != null)
      'catalog_number': json['catalog_number'],
    if (json['cover_image_key'] != null)
      'cover_image_key': json['cover_image_key'],
  });

  return CatalogVariantDto(
    id: id,
    name: name,
    variantType: _textValue(json['variant_type']),
    sku: _textValue(json['sku'] ?? json['catalog_number']),
    barcode: _textValue(json['barcode']),
    isbn: _textValue(json['isbn']),
    region: _textValue(json['region']),
    coverImageUrl: _textValue(json['cover_image_url']),
    description: _textValue(json['description']),
    physicalFormat: _textValue(json['physical_format']),
    physicalFormatLabel: _textValue(json['physical_format_label']),
    metadata: metadata.isEmpty ? null : metadata,
    isPrimary: json['is_primary'] == true,
  );
}

String? _textValue(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

DateTime? _dateValue(Object? value) =>
    DateTime.tryParse(value?.toString().trim() ?? '');
