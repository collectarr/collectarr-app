class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.kind,
    required this.title,
    this.itemNumber,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.editionTitle,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.publisher,
    this.releaseDate,
    this.releaseYear,
    this.barcode,
    this.variant,
  });

  final String id;
  final String kind;
  final String title;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? editionTitle;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? publisher;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;
  String? get displayEditionLabel =>
      physicalFormatLabel ?? variant ?? editionTitle;

  Map<String, dynamic> toSyncPayload() {
    return {
      'snapshot_version': 1,
      'kind': kind,
      'title': title,
      'item_number': itemNumber,
      'synopsis': synopsis,
      'cover_image_url': coverImageUrl,
      'thumbnail_image_url': thumbnailImageUrl,
      'edition_title': editionTitle,
      'physical_format': physicalFormat,
      'physical_format_label': physicalFormatLabel,
      'publisher': publisher,
      'release_date': releaseDate?.toUtc().toIso8601String(),
      'release_year': releaseYear,
      'barcode': barcode,
      'variant': variant,
    };
  }

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id'] as String,
      kind: json['kind'] as String,
      title: json['title'] as String,
      itemNumber: json['item_number'] as String?,
      synopsis: json['synopsis'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      editionTitle: json['edition_title'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      publisher: json['publisher'] as String?,
      releaseDate: _parseDate(json['release_date'] as String?),
      releaseYear: json['release_year'] as int?,
      barcode: json['barcode'] as String?,
      variant: json['variant'] as String?,
    );
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
