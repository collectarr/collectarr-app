import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
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

MangaCatalogFormValues mangaCatalogFormValuesFromMetadata(
  MangaMetadata metadata,
) {
  final values = MangaCatalogFormValues(
    title: metadata.title,
    originalLanguage: metadata.language,
    status: metadata.publicationStatus.label,
    originalPublicationDate: metadata.originalPublicationDate,
    genres: metadata.genres,
    seriesTitle: metadata.seriesTitle ?? '',
    seriesId: metadata.series?.seriesId ?? '',
    volumeNumber:
        metadata.itemNumber ?? metadata.volumeNumber?.toString() ?? '',
    authors: [...metadata.authors, ...metadata.artists].join(', '),
    description: _text(metadata.rawPayload['description']) ??
        _text(metadata.rawPayload['synopsis']) ??
        '',
    ageRating: _text(metadata.rawPayload['age_rating']) ?? '',
    country: metadata.country,
    publicationYear: _int(metadata.rawPayload['publication_date']) ??
        metadata.originalPublicationDate?.year,
    pageCount: metadata.pageCount,
    seriesGroup: _text(metadata.rawPayload['series_group']) ?? '',
    characters: _stringList(metadata.rawPayload['characters']).join(', '),
    releaseTitle: metadata.editionTitle ?? '',
    format: metadata.physicalFormat ?? metadata.editionFormat.label,
    binding: metadata.physicalFormatLabel ?? '',
    publisher: metadata.publisher ?? metadata.originalPublisher ?? '',
    imprint: metadata.imprint ?? metadata.localizedPublisher ?? '',
    isbn: metadata.isbn ?? '',
    barcode: metadata.barcode ?? '',
    language: metadata.language,
    region: metadata.country,
    releaseDate: metadata.localizedReleaseDate,
    releaseDescription: _text(metadata.rawPayload['description']) ?? '',
    coverImageUrl: metadata.coverImageUrl ?? '',
    backCoverImageUrl: _text(metadata.rawPayload['back_cover_image_url']) ?? '',
    variant: metadata.variant ?? '',
  );
  if (metadata.editions.isNotEmpty) {
    final primary = metadata.editions.first;
    final releaseValues = mangaCatalogFormValuesFromRelease(primary);
    values
      ..releaseTitle = releaseValues.releaseTitle
      ..format = releaseValues.format
      ..binding = releaseValues.binding
      ..publisher = releaseValues.publisher
      ..imprint = releaseValues.imprint
      ..distributor = releaseValues.distributor
      ..isbn = releaseValues.isbn
      ..barcode = releaseValues.barcode
      ..language = releaseValues.language
      ..region = releaseValues.region
      ..releaseDate = releaseValues.releaseDate
      ..pageCount = releaseValues.pageCount
      ..releaseDescription = releaseValues.releaseDescription
      ..coverImageUrl = releaseValues.coverImageUrl;
  }
  return values;
}

MangaCatalogFormValues mangaCatalogFormValuesFromRelease(
  CatalogEditionDto release,
) {
  final metadata = release.metadata ?? const <String, dynamic>{};
  return MangaCatalogFormValues(
    releaseTitle: release.title,
    format: release.format ?? release.physicalFormat ?? '',
    binding: release.physicalFormatLabel ?? _text(metadata['binding']) ?? '',
    publisher: release.publisher ?? '',
    imprint: _text(metadata['imprint']) ?? '',
    distributor: release.distributor ?? '',
    isbn: release.isbn ?? '',
    barcode: release.upc ?? _text(metadata['barcode']) ?? '',
    language: release.language ?? '',
    region: release.region ?? _text(metadata['country']) ?? '',
    releaseDate: release.releaseDate,
    releaseDateParts: release.releaseDateParts,
    pageCount: _int(metadata['page_count']),
    releaseDescription: _text(metadata['description']) ?? '',
    coverImageUrl: _text(metadata['cover_image_url']) ?? '',
  );
}

MangaMedia mangaMediaFromCatalogFormValues({
  required MangaMedia original,
  required MangaCatalogFormValues values,
}) {
  final raw = Map<String, dynamic>.from(original.rawPayload);
  _write(raw, 'title', values.title.trim());
  _write(raw, 'sort_title', _optional(values.sortTitle));
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

CatalogEditionDto mangaReleaseFromCatalogFormValues({
  required CatalogEditionDto original,
  required MangaCatalogFormValues values,
}) {
  final metadata = Map<String, dynamic>.from(original.metadata ?? const {});
  _write(metadata, 'imprint', _optional(values.imprint));
  _write(metadata, 'binding', _optional(values.binding));
  _write(metadata, 'page_count', values.pageCount);
  _write(metadata, 'description', _optional(values.releaseDescription));
  _write(metadata, 'cover_image_url', _optional(values.coverImageUrl));
  _write(metadata, 'barcode', _optional(values.barcode));
  _write(metadata, 'country', _optional(values.region));
  final releaseDate = values.releaseDate;
  final releaseDateParts = values.releaseDateEdited
      ? (releaseDate == null ? null : PartialDate.fromDateTime(releaseDate))
      : values.releaseDateParts;
  return CatalogEditionDto(
    id: original.id,
    title: values.releaseTitle.trim(),
    format: _optional(values.format),
    publisher: _optional(values.publisher),
    distributor: _optional(values.distributor),
    isbn: _optional(values.isbn),
    upc: _optional(values.barcode),
    language: _optional(values.language),
    region: _optional(values.region),
    releaseDate: releaseDate,
    releaseDateParts: releaseDateParts,
    physicalFormat: _optional(values.format),
    physicalFormatLabel: _optional(values.binding),
    metadata: metadata.isEmpty ? null : metadata,
    variants: original.variants,
    discs: original.discs,
  );
}

MangaMetadata mangaMetadataFromManualCatalogFormValues({
  required MangaCatalogFormValues values,
  required String id,
  required String title,
  CatalogSeriesDetailsDto? series,
}) {
  final normalizedTitle = title.trim();
  final publicationDate = values.publicationYear == null
      ? null
      : DateTime.utc(values.publicationYear!);
  final release = CatalogEditionDto(
    id: '$id-release',
    title: _optional(values.releaseTitle) ?? normalizedTitle,
    format: _optional(values.format),
    publisher: _optional(values.publisher),
    distributor: _optional(values.distributor),
    isbn: _optional(values.isbn),
    upc: _optional(values.barcode),
    language: _optional(values.language),
    region: _optional(values.region) ?? _optional(values.country),
    releaseDate: values.releaseDate,
    releaseDateParts: values.releaseDate == null
        ? null
        : PartialDate.fromDateTime(values.releaseDate!),
    physicalFormat: _optional(values.format),
    physicalFormatLabel: _optional(values.binding),
    metadata: {
      if (_optional(values.imprint) case final imprint?) 'imprint': imprint,
      if (values.pageCount != null) 'page_count': values.pageCount,
      if (_optional(values.releaseDescription) case final description?)
        'description': description,
      if (_optional(values.coverImageUrl) case final cover?)
        'cover_image_url': cover,
      if (_optional(values.barcode) case final barcode?) 'barcode': barcode,
      if (_optional(values.backCoverImageUrl) case final backCover?)
        'back_cover_image_url': backCover,
      if (_optional(values.variant) case final variant?) 'variant': variant,
    },
  );

  return MangaMetadata(
    title: normalizedTitle,
    authors: _split(values.authors),
    originalPublisher: _optional(values.publisher),
    localizedPublisher: _optional(values.imprint),
    volumeNumber: int.tryParse(values.volumeNumber.trim()),
    itemNumber: _optional(values.volumeNumber),
    originalPublicationDate: publicationDate,
    localizedReleaseDate: values.releaseDate,
    isbn: _optional(values.isbn),
    language: _optional(values.language) ?? 'ja',
    country: _optional(values.country) ?? 'JP',
    genres: List<String>.unmodifiable(values.genres),
    series: series ?? _manualSeries(values),
    seriesTitle: _optional(values.seriesTitle) ?? normalizedTitle,
    editionTitle: _optional(values.releaseTitle),
    pageCount: values.pageCount,
    imprint: _optional(values.imprint),
    physicalFormat: _optional(values.format),
    physicalFormatLabel: _optional(values.binding),
    publisher: _optional(values.publisher),
    barcode: _optional(values.barcode),
    variant: _optional(values.variant),
    editions: [release],
    rawPayload: {
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
      if (_optional(values.seriesGroup) case final group?)
        'series_group': group,
      if (_optional(values.backCoverImageUrl) case final backCover?)
        'back_cover_image_url': backCover,
      if (_optional(values.coverImageUrl) case final cover?)
        'cover_image_url': cover,
    },
  );
}

CatalogSeriesDetailsDto? _manualSeries(MangaCatalogFormValues values) {
  final title = _optional(values.seriesTitle);
  final group = _optional(values.seriesGroup);
  if (title == null && group == null && _optional(values.seriesId) == null) {
    return null;
  }
  return CatalogSeriesDetailsDto(
    seriesId: _optional(values.seriesId),
    seriesTitle: title ?? group,
    volumeName: group,
    volumeNumber: _optional(values.volumeNumber),
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

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _int(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value');

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
