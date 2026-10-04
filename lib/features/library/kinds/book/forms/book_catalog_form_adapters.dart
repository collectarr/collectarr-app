import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_values.dart';
import 'package:collectarr_app/core/models/partial_date.dart';

BookCatalogMetadata bookMetadataFromManualFormValues({
  required BookCatalogFormValues values,
  required String id,
  required String title,
}) {
  final releaseDate = values.releaseDate ??
      (values.publicationYear == null
          ? null
          : DateTime.utc(values.publicationYear!));
  return BookCatalogMetadata(
    transportId: id,
    title: title.trim(),
    sortTitle: _optional(values.sortTitle),
    subtitle: _optional(values.subtitle),
    editionTitle: _optional(values.editionTitle),
    editionStatement: _optional(values.editionStatement),
    seriesTitle: _optional(values.seriesTitle),
    seriesGroup: _optional(values.seriesGroup),
    itemNumber: _optional(values.number),
    publisher: _optional(values.publisher),
    distributor: _optional(values.distributor),
    imprint: _optional(values.imprint),
    pageCount: values.pageCount,
    creators: values.authors,
    contributors: values.translators,
    characters: [
      for (final name in _split(values.characters))
        BookCatalogCharacter(name: name),
    ],
    description: _optional(values.description),
    genres: values.genres,
    subjects: values.subjects,
    ageRating: _optional(values.ageRating),
    language: _optional(values.language),
    originalLanguage: _optional(values.originalLanguage),
    country: _optional(values.country),
    region: _optional(values.region),
    firstPublicationDate: values.firstPublicationDate,
    firstPublicationDateParts: values.firstPublicationDate == null
        ? null
        : PartialDate.fromDateTime(values.firstPublicationDate!),
    originalPublicationDate: values.originalPublicationDate,
    originalPublicationDateParts: values.originalPublicationDate == null
        ? null
        : PartialDate.fromDateTime(values.originalPublicationDate!),
    releaseDate: releaseDate,
    releaseDateParts: releaseDate == null
        ? null
        : values.releaseDate == null && values.publicationYear != null
            ? PartialDate(year: values.publicationYear)
            : PartialDate.fromDateTime(releaseDate),
    isbn: _optional(values.isbn),
    barcode: _optional(values.upc),
    variant: _optional(values.variant),
    binding: _optional(values.binding),
    physicalFormat: _optional(values.format),
    coverImageUrl: _optional(values.coverImageUrl),
    backCoverImageUrl: _optional(values.backCoverImageUrl),
    thumbnailImageUrl: _optional(values.thumbnailImageUrl),
    searchAliases: values.searchAliases,
    releaseStatus: _optional(values.releaseStatus),
    dimensions: _optional(values.dimensions),
    firstEdition: values.firstEdition,
    audioLengthMinutes: values.audioLengthMinutes,
  );
}

String? _optional(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toList(growable: false);
