import 'package:collectarr_app/core/api/dto/catalog/catalog_variant_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_disc_dto.dart';

class CatalogEditionDto {
  const CatalogEditionDto({
    required this.id,
    required this.title,
    this.format,
    this.publisher,
    this.distributor,
    this.isbn,
    this.upc,
    this.language,
    this.region,
    this.releaseDate,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.metadata,
    this.variants = const <CatalogVariantDto>[],
    this.discs = const <CatalogDiscDto>[],
  });

  final String id;
  final String title;
  final String? format;
  final String? publisher;
  final String? distributor;
  final String? isbn;
  final String? upc;
  final String? language;
  final String? region;
  final DateTime? releaseDate;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final Map<String, dynamic>? metadata;
  final List<CatalogVariantDto> variants;
  final List<CatalogDiscDto> discs;

  factory CatalogEditionDto.fromJson(Map<String, dynamic> json) {
    return CatalogEditionDto(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Edition',
      format: json['format'] as String?,
      publisher: json['publisher'] as String?,
      distributor: json['distributor'] as String?,
      isbn: json['isbn'] as String?,
      upc: json['upc'] as String?,
      language: json['language'] as String?,
      region: json['region'] as String?,
      releaseDate: _parseDate(json['release_date'] as String?),
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      metadata: const <String, dynamic>{},
      variants: (json['variants'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(CatalogVariantDto.fromJson)
              .toList(growable: false) ??
          const <CatalogVariantDto>[],
      discs: (json['discs'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(CatalogDiscDto.fromJson)
              .toList(growable: false) ??
          const <CatalogDiscDto>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (format != null) 'format': format,
      if (publisher != null) 'publisher': publisher,
      if (distributor != null) 'distributor': distributor,
      if (isbn != null) 'isbn': isbn,
      if (upc != null) 'upc': upc,
      if (language != null) 'language': language,
      if (region != null) 'region': region,
      if (releaseDate != null)
        'release_date': releaseDate!.toUtc().toIso8601String(),
      if (physicalFormat != null) 'physical_format': physicalFormat,
      if (physicalFormatLabel != null)
        'physical_format_label': physicalFormatLabel,
      'variants':
          variants.map((variant) => variant.toJson()).toList(growable: false),
      if (discs.isNotEmpty)
        'discs': discs.map((disc) => disc.toJson()).toList(growable: false),
    };
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }
}
