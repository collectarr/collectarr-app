/// Shared book domain types used by the workspace entry model and
/// the book catalog. Living here keeps them importable by boundary
/// files (workspace/entry/) without violating the kind-boundary rule.
library;

import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';

/// A reference to a single edition/variant of a book release.
class BookVariantRef {
  const BookVariantRef({
    required this.id,
    required this.name,
    this.variantType,
    this.sku,
    this.barcode,
    this.isbn,
    this.region,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final String? variantType;
  final String? sku;
  final String? barcode;
  final String? isbn;
  final String? region;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final bool isPrimary;
  String? get description => null;
}

/// A single release (edition) of a book work.
class BookRelease {
  const BookRelease({
    required this.id,
    required this.title,
    this.workId,
    this.titleValue,
    this.displayTitle,
    this.ageRating,
    this.audioLengthMinutes,
    this.binding,
    this.contributors = const [],
    this.coverImageKey,
    this.publisher,
    this.distributor,
    this.description,
    this.editionStatement,
    this.isbn,
    this.identifiers = const [],
    this.imprint,
    this.upc,
    this.pageCount,
    this.language,
    this.region,
    this.releaseDate,
    this.releaseStatus,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.dimensions,
    this.firstEdition,
    this.variants = const <BookVariantRef>[],
  });

  final String id;
  final String title;
  final String? workId;
  final String? titleValue;
  final String? displayTitle;
  final String? ageRating;
  final int? audioLengthMinutes;
  final String? binding;
  final List<dynamic> contributors;
  final String? coverImageKey;
  final String? publisher;
  final String? distributor;
  final String? description;
  final String? editionStatement;
  final String? isbn;
  final List<dynamic> identifiers;
  final String? imprint;
  final String? upc;
  final int? pageCount;
  final String? language;
  final String? region;
  final DateTime? releaseDate;
  final String? releaseStatus;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? dimensions;
  final bool? firstEdition;
  final List<BookVariantRef> variants;

  BookReleaseId get typedId => BookReleaseId(id);

  factory BookRelease.fromJson(Map<String, dynamic> json) {
    return BookRelease(
      id: json['id']?.toString() ?? '',
      title: (json['display_title'] ?? json['title'] ?? 'Edition').toString(),
      workId: json['work_id']?.toString(),
      titleValue: json['title']?.toString(),
      displayTitle: json['display_title']?.toString(),
      ageRating: json['age_rating']?.toString(),
      audioLengthMinutes: _intValue(json['audio_length_minutes']),
      binding: json['binding']?.toString(),
      contributors: _list(json['contributors']),
      coverImageKey: json['cover_image_key']?.toString(),
      publisher: json['publisher']?.toString(),
      distributor: json['distributor']?.toString(),
      description: json['description']?.toString(),
      editionStatement: json['edition_statement']?.toString(),
      isbn: json['isbn']?.toString(),
      identifiers: _list(json['identifiers']),
      imprint: json['imprint']?.toString(),
      upc: json['upc']?.toString(),
      pageCount: _intValue(json['page_count']),
      language: json['language']?.toString(),
      region: json['region']?.toString(),
      releaseDate: _dateValue(json['publication_date'] ?? json['release_date']),
      releaseStatus: json['release_status']?.toString(),
      physicalFormat: (json['physical_format'] ?? json['format'])?.toString(),
      physicalFormatLabel: json['physical_format_label']?.toString(),
      coverImageUrl: json['cover_image_url']?.toString(),
      thumbnailImageUrl: json['thumbnail_image_url']?.toString(),
      dimensions: json['dimensions']?.toString(),
      firstEdition: json['first_edition'] as bool?,
      variants: _variants(json['variants']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': titleValue ?? title,
        if (workId != null) 'work_id': workId,
        if (displayTitle != null) 'display_title': displayTitle,
        if (ageRating != null) 'age_rating': ageRating,
        if (audioLengthMinutes != null)
          'audio_length_minutes': audioLengthMinutes,
        if (binding != null) 'binding': binding,
        if (contributors.isNotEmpty) 'contributors': contributors,
        if (coverImageKey != null) 'cover_image_key': coverImageKey,
        if (publisher != null) 'publisher': publisher,
        if (distributor != null) 'distributor': distributor,
        if (description != null) 'description': description,
        if (editionStatement != null) 'edition_statement': editionStatement,
        if (isbn != null) 'isbn': isbn,
        if (identifiers.isNotEmpty) 'identifiers': identifiers,
        if (imprint != null) 'imprint': imprint,
        if (upc != null) 'upc': upc,
        if (pageCount != null) 'page_count': pageCount,
        if (language != null) 'language': language,
        if (region != null) 'region': region,
        if (releaseDate != null)
          'publication_date': releaseDate!.toIso8601String(),
        if (releaseStatus != null) 'release_status': releaseStatus,
        if (physicalFormat != null) 'format': physicalFormat,
        if (physicalFormatLabel != null)
          'physical_format_label': physicalFormatLabel,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
        if (dimensions != null) 'dimensions': dimensions,
        if (firstEdition != null) 'first_edition': firstEdition,
        if (variants.isNotEmpty)
          'variants': variants
              .map((variant) => {
                    'id': variant.id,
                    'name': variant.name,
                    if (variant.variantType != null)
                      'variant_type': variant.variantType,
                    if (variant.sku != null) 'sku': variant.sku,
                    if (variant.barcode != null) 'barcode': variant.barcode,
                    if (variant.isbn != null) 'isbn': variant.isbn,
                    if (variant.region != null) 'region': variant.region,
                    if (variant.coverImageUrl != null)
                      'cover_image_url': variant.coverImageUrl,
                    if (variant.thumbnailImageUrl != null)
                      'thumbnail_image_url': variant.thumbnailImageUrl,
                    if (variant.physicalFormat != null)
                      'physical_format': variant.physicalFormat,
                    if (variant.physicalFormatLabel != null)
                      'physical_format_label': variant.physicalFormatLabel,
                    if (variant.isPrimary) 'is_primary': true,
                  })
              .toList(),
      };

  static int? _intValue(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime? _dateValue(Object? value) {
    return DateTime.tryParse(value?.toString() ?? '');
  }

  static List<dynamic> _list(Object? value) {
    return value is List ? List<dynamic>.from(value) : const <dynamic>[];
  }

  static List<BookVariantRef> _variants(Object? value) {
    if (value is! List) return const <BookVariantRef>[];
    return [
      for (final entry in value)
        if (entry is Map<Object?, Object?>)
          BookVariantRef(
            id: entry['id']?.toString() ?? '',
            name: entry['name']?.toString() ?? 'Variant',
            variantType: entry['variant_type']?.toString(),
            sku: entry['sku']?.toString(),
            barcode: entry['barcode']?.toString(),
            isbn: entry['isbn']?.toString(),
            region: entry['region']?.toString(),
            coverImageUrl: entry['cover_image_url']?.toString(),
            thumbnailImageUrl: entry['thumbnail_image_url']?.toString(),
            physicalFormat: entry['physical_format']?.toString(),
            physicalFormatLabel: entry['physical_format_label']?.toString(),
            isPrimary: entry['is_primary'] == true,
          ),
    ];
  }
}

/// Optional local-storage paths for physical book cover images.
class BookPhysicalDetails {
  const BookPhysicalDetails({
    this.coverImagePath,
    this.thumbnailImagePath,
    this.backImagePath,
    this.dimensions,
    this.printing,
    this.firstEdition,
    this.dustJacket,
    this.numberLine,
  });

  final String? coverImagePath;
  final String? thumbnailImagePath;
  final String? backImagePath;
  final String? dimensions;
  final String? printing;
  final bool? firstEdition;
  final bool? dustJacket;
  final String? numberLine;
}

/// Original publication details carried on a book catalog item.
class BookOriginalDetails {
  const BookOriginalDetails({
    this.originalTitle,
    this.originalPublisher,
    this.originalLanguage,
    this.originalCountry,
    this.originalPublicationDate,
    this.originalPublicationPlace,
    this.dewey,
    this.lccn,
    this.locControlNumber,
  });

  final String? originalTitle;
  final String? originalPublisher;
  final String? originalLanguage;
  final String? originalCountry;
  final DateTime? originalPublicationDate;
  final String? originalPublicationPlace;
  final String? dewey;
  final String? lccn;
  final String? locControlNumber;

  String? get publisher => originalPublisher;
}
