import 'package:collectarr_app/core/models/catalog_item.dart';

class CatalogMetadataDto {
  const CatalogMetadataDto({
    required this.raw,
    required this.id,
    required this.title,
    this.kind,
    this.releaseDate,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.barcode,
    this.tracks = const <CatalogTrack>[],
  });

  final Map<String, dynamic> raw;
  final String id;
  final String title;
  final String? kind;
  final DateTime? releaseDate;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? barcode;
  final List<CatalogTrack> tracks;

  factory CatalogMetadataDto.fromJson(Map<String, dynamic> json) {
    return CatalogMetadataDto(
      raw: Map<String, dynamic>.from(json),
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled item',
      kind: json['kind']?.toString(),
      releaseDate: _parseDate(json['release_date'] ?? json['releaseDate']),
      coverImageUrl: json['cover_image_url']?.toString(),
      thumbnailImageUrl: json['thumbnail_image_url']?.toString(),
      barcode: json['barcode']?.toString(),
      tracks: [
        for (final track in (json['tracks'] as List<dynamic>? ?? const []))
          if (track is Map<String, dynamic>) CatalogTrack.fromJson(track),
      ],
    );
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);

  CatalogItem toCatalogItem() => CatalogItem.fromJson(toJson());

  static DateTime? _parseDate(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
