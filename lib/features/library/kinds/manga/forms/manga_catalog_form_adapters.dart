import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_form_values.dart';
import 'package:collectarr_app/core/models/partial_date.dart';

MangaMetadata mangaMetadataFromManualCatalogFormValues({
  required MangaCatalogFormValues values,
  required String id,
  required String title,
}) {
  final normalizedTitle = title.trim();
  final publicationDate = values.publicationYear == null
      ? null
      : DateTime.utc(values.publicationYear!);
  final isbn = _optional(values.isbn);
  final barcode = _optional(values.barcode);
  return MangaMetadata(
    title: normalizedTitle,
    authors: _split(values.authors),
    artists: _split(values.artists),
    creators: [
      for (final author in _split(values.authors))
        MangaCredit(name: author, role: 'author'),
      for (final artist in _split(values.artists))
        MangaCredit(name: artist, role: 'artist'),
    ],
    demographic: MangaDemographic.fromString(values.demographic),
    publicationStatus: MangaPublicationStatus.fromString(values.status),
    releaseStatus: _optional(values.status),
    serializationPlatform: _optional(values.serializationPlatform),
    originalPublisher: _optional(values.publisher),
    localizedPublisher: _optional(values.imprint),
    volumeNumber: int.tryParse(values.volumeNumber.trim()),
    seriesGroup: _optional(values.seriesGroup),
    originalPublicationDate: publicationDate,
    localizedReleaseDate: values.releaseDate,
    isbn: isbn,
    language: _optional(values.language) ??
        _optional(values.originalLanguage) ??
        'ja',
    country: _optional(values.country) ?? 'JP',
    genres: List<String>.unmodifiable(values.genres),
    themes: List<String>.unmodifiable(values.themes),
    seriesTitle: _optional(values.seriesTitle),
    editionTitle: _optional(values.releaseTitle),
    pageCount: values.pageCount,
    imprint: _optional(values.imprint),
    physicalFormat: _optional(values.format),
    physicalFormatLabel: _optional(values.binding),
    publisher: _optional(values.publisher),
    barcode: barcode,
    variant: _optional(values.variant),
    sortKey: _optional(values.sortTitle),
    searchAliases: List<String>.unmodifiable(values.searchAliases),
    subtitle: _optional(values.subtitle),
    description: _optional(values.releaseDescription),
    synopsis: _optional(values.description),
    plotDescription: _optional(values.description),
    titleExtension: _optional(values.releaseTitle),
    characters: [
      for (final character in _split(values.characters))
        MangaCharacter(name: character, plainValue: true),
    ],
    ageRating: _optional(values.ageRating),
    coverImageUrl: _optional(values.coverImageUrl),
    backCoverImageUrl: _optional(values.backCoverImageUrl),
    identifiers: [
      if (isbn != null)
        MangaIdentifier(
          identifierType: 'isbn',
          value: isbn,
          isPrimary: true,
        ),
      if (barcode != null)
        MangaIdentifier(
          identifierType: 'barcode',
          value: barcode,
          isPrimary: isbn == null,
        ),
    ],
    releaseDateParts: values.releaseDateParts ??
        (values.releaseDate == null
            ? null
            : PartialDate.fromDateTime(values.releaseDate!)),
  );
}

String? _optional(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
