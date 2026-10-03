import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_form_values.dart';

MangaMetadata mangaMetadataFromManualCatalogFormValues({
  required MangaCatalogFormValues values,
  required String id,
  required String title,
}) {
  final normalizedTitle = title.trim();
  final publicationDate = values.publicationYear == null
      ? null
      : DateTime.utc(values.publicationYear!);
  return MangaMetadata(
    title: normalizedTitle,
    authors: _split(values.authors),
    originalPublisher: _optional(values.publisher),
    localizedPublisher: _optional(values.imprint),
    volumeNumber: int.tryParse(values.volumeNumber.trim()),
    volumeName: _optional(values.seriesGroup),
    originalPublicationDate: publicationDate,
    localizedReleaseDate: values.releaseDate,
    isbn: _optional(values.isbn),
    language: _optional(values.language) ?? 'ja',
    country: _optional(values.country) ?? 'JP',
    genres: List<String>.unmodifiable(values.genres),
    seriesTitle: _optional(values.seriesTitle),
    editionTitle: _optional(values.releaseTitle),
    pageCount: values.pageCount,
    imprint: _optional(values.imprint),
    physicalFormat: _optional(values.format),
    physicalFormatLabel: _optional(values.binding),
    publisher: _optional(values.publisher),
    barcode: _optional(values.barcode),
    variant: _optional(values.variant),
    rawPayload: {
      if (_optional(values.sortTitle) case final sortKey?) 'sort_key': sortKey,
      if (_optional(values.characters) case final characters?)
        'characters': _split(characters),
      if (_optional(values.ageRating) case final ageRating?)
        'age_rating': ageRating,
      if (_optional(values.description) case final description?) ...{
        'description': description,
        'synopsis': description,
      },
      if (_optional(values.country) case final country?) 'country': country,
      if (publicationDate != null)
        'publication_date': publicationDate.toIso8601String(),
      if (_optional(values.backCoverImageUrl) case final backCover?)
        'back_cover_image_url': backCover,
      if (_optional(values.coverImageUrl) case final cover?)
        'cover_image_url': cover,
    },
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
