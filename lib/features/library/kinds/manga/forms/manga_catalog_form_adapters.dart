import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_form_values.dart';

MangaCatalogFormValues mangaCatalogFormValuesFromMedia(MangaMedia media) {
  final raw = media.rawPayload;
  return MangaCatalogFormValues(
    title: media.title,
    sortTitle: media.sortTitle ?? '',
    subtitle: media.subtitle ?? '',
    description: media.description ?? '',
    originalLanguage: media.originalLanguage ?? '',
    status: media.status ?? '',
    firstPublicationDate: media.firstPublicationDate,
    originalPublicationDate: media.originalPublicationDate,
    genres: _stringList(raw['genres']),
    searchAliases: _stringList(raw['search_aliases']),
  );
}

MangaMedia mangaMediaFromCatalogFormValues({
  required MangaMedia original,
  required MangaCatalogFormValues values,
}) {
  final raw = Map<String, dynamic>.from(original.rawPayload);
  _write(raw, 'title', values.title.trim());
  _write(raw, 'sort_key', _optional(values.sortTitle));
  _write(raw, 'subtitle', _optional(values.subtitle));
  _write(raw, 'description', _optional(values.description));
  _write(raw, 'synopsis', _optional(values.description));
  _write(raw, 'original_language', _optional(values.originalLanguage));
  _write(raw, 'status', _optional(values.status));
  _write(raw, 'first_publication_date',
      values.firstPublicationDate?.toIso8601String());
  _write(raw, 'original_publication_date',
      values.originalPublicationDate?.toIso8601String());
  raw['genres'] = List<String>.unmodifiable(values.genres);
  raw['search_aliases'] = List<String>.unmodifiable(values.searchAliases);

  return MangaMedia(
    id: original.id,
    title: values.title.trim(),
    sortTitle: _optional(values.sortTitle),
    subtitle: _optional(values.subtitle),
    description: _optional(values.description),
    originalLanguage: _optional(values.originalLanguage),
    status: _optional(values.status),
    firstPublicationDate: values.firstPublicationDate,
    originalPublicationDate: values.originalPublicationDate,
    chapters: original.chapters,
    characterAppearances: original.characterAppearances,
    contributions: original.contributions,
    identifiers: original.identifiers,
    series: original.series,
    rawPayload: raw,
  );
}

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

void _write(Map<String, dynamic> target, String key, Object? value) {
  if (value == null || value is String && value.trim().isEmpty) {
    target.remove(key);
  } else {
    target[key] = value;
  }
}

String? _optional(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

List<String> _stringList(Object? value) => value is Iterable
    ? value
        .map((entry) => entry.toString().trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false)
    : const <String>[];

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
