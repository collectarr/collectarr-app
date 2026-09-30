import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_values.dart';

BookCatalogMetadata bookMetadataFromManualFormValues({
  required BookCatalogFormValues values,
  required String id,
  required String title,
}) {
  final year = values.publicationYear;
  return BookCatalogMetadata.fromJson({
    'id': id,
    'title': title.trim(),
    'subtitle': _optional(values.editionTitle),
    'edition_title': _optional(values.editionTitle),
    'series_title':
        _optional(values.seriesTitle) ?? _optional(values.seriesGroup),
    'item_number': _optional(values.number),
    'original_publisher': _optional(values.publisher),
    'publisher': _optional(values.publisher),
    'distributor': _optional(values.distributor),
    'imprint': _optional(values.imprint),
    'page_count': values.pageCount,
    'authors': _split(values.authors),
    'characters': _split(values.characters),
    'synopsis': _optional(values.description),
    'genres': values.genres,
    'age_rating': _optional(values.ageRating),
    'language': _optional(values.language),
    'country': _optional(values.country),
    'original_publication_date':
        year == null ? null : DateTime.utc(year).toIso8601String(),
    'publication_date': values.releaseDate?.toIso8601String(),
    'isbn': _optional(values.isbn) ?? _optional(values.upc),
    'barcode': _optional(values.upc) ?? _optional(values.isbn),
    'variant': _optional(values.variant),
    'physical_format_label': _optional(values.format),
    'physical_format': _optional(values.format),
    'cover_image_url': _optional(values.coverImageUrl),
    'back_cover_image_url': _optional(values.backCoverImageUrl),
    'contributors': _split(values.authors),
  });
}

String? _optional(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
