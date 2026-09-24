import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_values.dart';

BookCatalogFormValues bookCatalogFormValuesFromMedia(BookMedia media) =>
    BookCatalogFormValues(
      title: media.title,
      sortTitle: media.sortTitle ?? '',
      subtitle: media.subtitle ?? '',
      description: media.description ?? '',
      originalLanguage: media.originalLanguage ?? '',
      firstPublicationDate: media.firstPublicationDate,
      originalPublicationDate: media.originalPublicationDate,
      genres: media.genres,
      searchAliases: media.searchAliases,
    );

BookCatalogFormValues bookCatalogFormValuesFromRelease(BookRelease release) =>
    BookCatalogFormValues(
      editionTitle: release.title,
      binding: release.binding ?? '',
      format: release.physicalFormat ?? release.physicalFormatLabel ?? '',
      isbn: release.isbn ?? '',
      upc: release.upc ?? '',
      publisher: release.publisher ?? '',
      distributor: release.distributor ?? '',
      imprint: release.imprint ?? '',
      releaseDate: release.releaseDate,
      pageCount: release.pageCount,
      language: release.language ?? '',
      region: release.region ?? '',
      releaseStatus: release.releaseStatus ?? '',
      editionStatement: release.editionStatement ?? '',
      description: release.description ?? '',
      dimensions: release.dimensions ?? '',
      firstEdition: release.firstEdition ?? false,
      audioLengthMinutes: release.audioLengthMinutes,
      ageRating: release.ageRating ?? '',
      coverImageUrl: release.coverImageUrl ?? '',
      thumbnailImageUrl: release.thumbnailImageUrl ?? '',
    );

BookMedia bookMediaFromCatalogFormValues({
  required BookMedia original,
  required BookCatalogFormValues values,
}) {
  final raw = Map<String, dynamic>.from(original.rawPayload);
  _write(raw, 'title', values.title.trim());
  _write(raw, 'sort_title', _optional(values.sortTitle));
  _write(raw, 'subtitle', _optional(values.subtitle));
  _write(raw, 'description', _optional(values.description));
  _write(raw, 'original_language', _optional(values.originalLanguage));
  _write(raw, 'first_publication_date',
      values.firstPublicationDate?.toIso8601String());
  _write(raw, 'original_publication_date',
      values.originalPublicationDate?.toIso8601String());
  raw['genres'] = List<String>.unmodifiable(values.genres);
  raw['search_aliases'] = List<String>.unmodifiable(values.searchAliases);
  return BookMedia(
    id: original.id,
    title: values.title.trim(),
    sortTitle: _optional(values.sortTitle),
    description: _optional(values.description),
    firstPublicationDate: values.firstPublicationDate,
    originalLanguage: _optional(values.originalLanguage),
    originalPublicationDate: values.originalPublicationDate,
    subtitle: _optional(values.subtitle),
    searchAliases: List<String>.unmodifiable(values.searchAliases),
    genres: List<String>.unmodifiable(values.genres),
    contributors: original.contributors,
    editions: original.editions,
    series: original.series,
    rawPayload: raw,
  );
}

BookRelease bookReleaseFromCatalogFormValues({
  required BookRelease original,
  required BookCatalogFormValues values,
}) {
  final date = values.releaseDate;
  return BookRelease(
    id: original.id,
    title: _optional(values.editionTitle) ?? original.title,
    workId: original.workId,
    titleValue: _optional(values.editionTitle),
    displayTitle: _optional(values.editionTitle),
    ageRating: _optional(values.ageRating),
    audioLengthMinutes: values.audioLengthMinutes,
    binding: _optional(values.binding),
    contributors: original.contributors,
    coverImageKey: original.coverImageKey,
    publisher: _optional(values.publisher),
    distributor: _optional(values.distributor),
    description: _optional(values.description),
    editionStatement: _optional(values.editionStatement),
    isbn: _optional(values.isbn),
    identifiers: original.identifiers,
    imprint: _optional(values.imprint),
    upc: _optional(values.upc),
    pageCount: values.pageCount,
    language: _optional(values.language),
    region: _optional(values.region),
    releaseDate: date,
    releaseStatus: _optional(values.releaseStatus),
    physicalFormat: _optional(values.format),
    physicalFormatLabel: _optional(values.binding) ?? _optional(values.format),
    coverImageUrl: _optional(values.coverImageUrl),
    thumbnailImageUrl: _optional(values.thumbnailImageUrl),
    dimensions: _optional(values.dimensions),
    firstEdition: values.firstEdition,
    variants: original.variants,
  );
}

BookMedia bookMediaWithRelease(BookMedia original, BookRelease release) {
  final editions = [
    for (final existing in original.editions)
      existing.id == release.id ? release : existing,
  ];
  return BookMedia(
    id: original.id,
    title: original.title,
    sortTitle: original.sortTitle,
    description: original.description,
    firstPublicationDate: original.firstPublicationDate,
    originalLanguage: original.originalLanguage,
    originalPublicationDate: original.originalPublicationDate,
    subtitle: original.subtitle,
    searchAliases: original.searchAliases,
    genres: original.genres,
    contributors: original.contributors,
    editions: editions,
    series: original.series,
    rawPayload: {
      ...original.rawPayload,
      'editions': editions.map((edition) => edition.toJson()).toList(),
    },
  );
}

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

void _write(Map<String, dynamic> target, String key, Object? value) {
  if (value == null || value is String && value.trim().isEmpty) {
    target.remove(key);
  } else {
    target[key] = value;
  }
}

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
