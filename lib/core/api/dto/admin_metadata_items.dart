part of 'admin_metadata.dart';

class AdminMetadataItem {
  const AdminMetadataItem({
    required this.id,
    required this.kind,
    required this.title,
    this.canonicalFieldValues = const <String, dynamic>{},
    this.itemNumber,
    this.editions = const [],
  });

  final String id;
  final String kind;
  final String title;

  /// Uninterpreted canonical field values from the Admin transport response.
  /// Kind contributors interpret these values; the API DTO keeps the payload
  /// opaque so it does not become a second field registry.
  final Map<String, dynamic> canonicalFieldValues;
  final String? itemNumber;
  final List<AdminEdition> editions;

  String get displayTitle {
    if (itemNumber == null || itemNumber!.isEmpty) {
      return title;
    }
    return '$title #$itemNumber';
  }

  AdminVariant? get primaryVariant {
    for (final edition in editions) {
      for (final variant in edition.variants) {
        if (variant.isPrimary) {
          return variant;
        }
      }
      if (edition.variants.isNotEmpty) {
        return edition.variants.first;
      }
    }
    return null;
  }

  AdminEdition? get primaryEdition => editions.isEmpty ? null : editions.first;

  String? get displayCoverUrl =>
      primaryVariant?.thumbnailImageUrl ?? primaryVariant?.coverImageUrl;

  factory AdminMetadataItem.fromJson(Map<String, dynamic> json) {
    return AdminMetadataItem(
      id: json['id']?.toString() ?? '',
      kind: json['kind'] as String? ?? '',
      title: json['title'] as String? ?? '',
      canonicalFieldValues: {
        if (json['normalized'] is Map)
          ...(json['normalized'] as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        for (final entry in json.entries)
          if (entry.key != 'normalized' && entry.value != null)
            entry.key: entry.value,
      },
      itemNumber: json['item_number'] as String?,
      editions: [
        for (final edition in (json['editions'] as List<dynamic>? ?? []))
          AdminEdition.fromJson(edition as Map<String, dynamic>),
      ],
    );
  }
}

class AdminEdition {
  const AdminEdition({
    required this.id,
    required this.title,
    this.publisher,
    this.releaseDate,
    this.releaseDateParts,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.variants = const [],
  });

  final String id;
  final String title;
  final String? publisher;
  final DateTime? releaseDate;
  final PartialDate? releaseDateParts;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final List<AdminVariant> variants;

  String? get formatLabel => physicalFormatLabel ?? physicalFormat;

  factory AdminEdition.fromJson(Map<String, dynamic> json) {
    return AdminEdition(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      publisher: json['publisher'] as String?,
      releaseDateParts: PartialDate.tryParse(
        json['release_date_parts'] ?? json['release_date'],
      ),
      releaseDate: PartialDate.tryParse(
        json['release_date_parts'] ?? json['release_date'],
      )?.asDateTime,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      variants: [
        for (final variant in (json['variants'] as List<dynamic>? ?? []))
          AdminVariant.fromJson(variant as Map<String, dynamic>),
      ],
    );
  }
}

class AdminVariant {
  const AdminVariant({
    required this.id,
    required this.name,
    required this.isPrimary,
    this.variantType,
    this.barcode,
    this.coverPriceCents,
    this.currency,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.physicalFormat,
    this.physicalFormatLabel,
  });

  final String id;
  final String name;
  final bool isPrimary;
  final String? variantType;
  final String? barcode;

  String? get identifierCode => barcode;
  final int? coverPriceCents;
  final String? currency;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? physicalFormat;
  final String? physicalFormatLabel;

  String? get formatLabel => physicalFormatLabel ?? physicalFormat;

  String get coverStatus {
    if (coverImageUrl == null && thumbnailImageUrl == null) {
      return 'missing';
    }
    return 'external_url';
  }

  String? get coverStorage => null;
  String? get coverPolicy => null;
  String? get coverSourceUrl => null;

  factory AdminVariant.fromJson(Map<String, dynamic> json) {
    return AdminVariant(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
      variantType: json['variant_type'] as String?,
      barcode: json['barcode'] as String?,
      coverPriceCents: json['cover_price_cents'] as int?,
      currency: json['currency'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
    );
  }
}

DateTime? _parseDateTime(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toUtc();
}

String _shortModelId(String id) => id.length <= 8 ? id : id.substring(0, 8);
