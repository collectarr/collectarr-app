import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';

GameCatalogFormValues gameCatalogFormValuesFromMedia(GameMedia media) {
  final release = media.primaryRelease;
  final raw = media.rawPayload;
  return GameCatalogFormValues(
    title: media.title,
    sortTitle: media.sortTitle ?? '',
    subtitle: media.subtitle ?? '',
    description: media.description ?? '',
    publisher: media.publisher ?? '',
    platforms: media.platforms,
    identifiers: media.identifiers,
    companyRoles: media.companyRoles,
    developers: _stringList(raw['developers']),
    ageRatings: media.ageRatings,
    genres: media.genres,
    searchAliases: media.searchAliases,
    originalLanguage: media.originalLanguage ?? '',
    workReleaseDate: media.releaseDate,
    franchise: _text(raw['franchise']) ?? '',
    series: _seriesText(raw['series']) ?? _text(raw['series_title']) ?? '',
    languages: _stringList(raw['languages']),
    country: _text(raw['country']) ?? 'US',
    releaseTitle: release?.title ?? '',
    platform: release?.platform ?? media.platforms.firstOrNull ?? '',
    region: release?.regionCode ?? '',
    format: release?.format ?? '',
    releaseDate: release?.releaseDate,
    releasePublisher: release?.publisher ?? '',
    catalogNumber: release?.catalogNumber ?? '',
    releaseStatus: release?.releaseStatus ?? '',
    language: release?.language ?? '',
    barcode: release?.barcode ?? '',
    coverImageUrl: release?.coverImageUrl ?? media.coverImageUrl ?? '',
    releaseYear: _integer(release?.rawPayload['release_year']) ??
        release?.releaseDate?.year,
    variant: _text(release?.rawPayload['variant']) ?? '',
    backCoverImageUrl:
        _text(release?.rawPayload['back_cover_image_url']) ?? '',
  );
}

GameCatalogFormValues gameCatalogFormValuesFromRelease(GameRelease release) =>
    GameCatalogFormValues(
      releaseTitle: release.title,
      platform: release.platform ?? '',
      region: release.regionCode ?? '',
      format: release.format ?? '',
      releaseDate: release.releaseDate,
      releasePublisher: release.publisher ?? '',
      catalogNumber: release.catalogNumber ?? '',
      releaseStatus: release.releaseStatus ?? '',
      language: release.language ?? '',
      barcode: release.barcode ?? '',
      coverImageUrl: release.coverImageUrl ?? '',
      releaseYear: _integer(release.rawPayload['release_year']) ??
          release.releaseDate?.year,
      variant: _text(release.rawPayload['variant']) ?? '',
      backCoverImageUrl:
          _text(release.rawPayload['back_cover_image_url']) ?? '',
    );

GameMedia gameMediaFromCatalogFormValues({
  required GameMedia original,
  required GameCatalogFormValues values,
}) {
  final raw = _withoutKeys(original.rawPayload, const {
    'title',
    'sort_title',
    'subtitle',
    'description',
    'release_date',
    'original_language',
    'publisher',
    'platforms',
    'identifiers',
    'company_roles',
    'age_ratings',
    'genres',
    'search_aliases',
  });
  _write(raw, 'developers', values.developers);
  _write(raw, 'franchise', values.franchise);
  _write(raw, 'series', values.series);
  _write(raw, 'languages', values.languages);
  _write(raw, 'country', values.country);
  return GameMedia(
    id: original.id,
    title: _optional(values.title) ?? original.title,
    sortTitle: _optional(values.sortTitle),
    description: _optional(values.description),
    releaseDate: values.workReleaseDate,
    originalLanguage: _optional(values.originalLanguage),
    publisher: _optional(values.publisher),
    subtitle: _optional(values.subtitle),
    platforms: List<String>.unmodifiable(values.platforms),
    identifiers: List<String>.unmodifiable(values.identifiers),
    companyRoles: List<String>.unmodifiable(values.companyRoles),
    ageRatings: List<String>.unmodifiable(values.ageRatings),
    genres: List<String>.unmodifiable(values.genres),
    searchAliases: List<String>.unmodifiable(values.searchAliases),
    releases: original.releases,
    rawPayload: raw,
  );
}

GameRelease gameReleaseFromCatalogFormValues({
  required GameRelease original,
  required GameCatalogFormValues values,
}) {
  final raw = _withoutKeys(original.rawPayload, const {
    'id',
    'kind',
    'work_id',
    'title',
    'release_title',
    'platform',
    'release_date',
    'region_code',
    'region',
    'format',
    'publisher',
    'catalog_number',
    'release_status',
    'language',
    'barcode',
    'cover_image_url',
  });
  _write(raw, 'release_year', values.releaseYear);
  _write(raw, 'variant', values.variant);
  _write(raw, 'back_cover_image_url', values.backCoverImageUrl);
  return GameRelease(
    id: original.id,
    title: _optional(values.releaseTitle) ?? original.title,
    workId: original.workId,
    platform: _optional(values.platform),
    releaseDate: values.releaseDate,
    regionCode: _optional(values.region),
    format: _optional(values.format),
    publisher: _optional(values.releasePublisher),
    catalogNumber: _optional(values.catalogNumber),
    releaseStatus: _optional(values.releaseStatus),
    language: _optional(values.language),
    barcode: _optional(values.barcode),
    coverImageUrl: _optional(values.coverImageUrl),
    rawPayload: raw,
  );
}

GameMedia gameMediaWithRelease(GameMedia original, GameRelease release) {
  final releases = [
    for (final current in original.releases)
      current.id == release.id ? release : current,
  ];
  return GameMedia(
    id: original.id,
    title: original.title,
    sortTitle: original.sortTitle,
    description: original.description,
    releaseDate: original.releaseDate,
    originalLanguage: original.originalLanguage,
    publisher: original.publisher,
    subtitle: original.subtitle,
    platforms: original.platforms,
    identifiers: original.identifiers,
    companyRoles: original.companyRoles,
    ageRatings: original.ageRatings,
    genres: original.genres,
    searchAliases: original.searchAliases,
    releases: releases,
    rawPayload: {
      ...original.rawPayload,
      'releases': [for (final entry in releases) entry.toJson()],
    },
  );
}

GameCatalogMetadata gameMetadataFromManualFormValues({
  required GameCatalogFormValues values,
  required String id,
  required String title,
}) {
  final releaseDate = _effectiveReleaseDate(values);
  final publisher = _optional(values.publisher);
  final releasePublisher = _optional(values.releasePublisher);
  final developers = values.developers;
  return GameCatalogMetadata.fromJson({
    'id': id,
    'title': title.trim(),
    'edition': _optional(values.releaseTitle),
    'sort_title': _optional(values.sortTitle),
    'subtitle': _optional(values.subtitle),
    'description': _optional(values.description),
    'synopsis': _optional(values.description),
    'platform': _optional(values.platform),
    'platforms': values.platforms.isNotEmpty
        ? values.platforms
        : [_optional(values.platform)].whereType<String>().toList(),
    'release_region': _optional(values.region),
    'release_date': releaseDate?.toIso8601String(),
    'publisher': releasePublisher ?? publisher,
    'publishers': [releasePublisher ?? publisher].whereType<String>().toList(),
    'barcode': _optional(values.barcode),
    'variant': _optional(values.variant),
    'catalog_number': _optional(values.catalogNumber),
    'physical_format_label': _optional(values.format),
    'physical_format': _optional(values.format),
    'cover_image_url': _optional(values.coverImageUrl),
    'back_cover_image_url': _optional(values.backCoverImageUrl),
    'developers': developers,
    'franchise': _optional(values.franchise),
    'series': _optional(values.series),
    'genres': values.genres,
    'age_rating': values.ageRatings.firstOrNull,
    'age_ratings': values.ageRatings,
    'languages': values.languages.isNotEmpty
        ? values.languages
        : [_optional(values.language)].whereType<String>().toList(),
    'language': _optional(values.language),
    'country': _optional(values.country) ?? 'US',
    'original_language': _optional(values.originalLanguage),
    'release_year': values.releaseYear,
    'identifiers': values.identifiers,
    'company_roles': values.companyRoles,
  });
}

Map<String, dynamic> _withoutKeys(
  Map<String, dynamic> source,
  Set<String> keys,
) =>
    {
      for (final entry in source.entries)
        if (!keys.contains(entry.key)) entry.key: entry.value,
    };

DateTime? _effectiveReleaseDate(GameCatalogFormValues values) {
  final year = values.releaseYear;
  final date = values.releaseDate;
  if (year == null || year < 1) return date;
  if (date == null) return DateTime.utc(year);
  return date.year == year ? date : DateTime.utc(year, date.month, date.day);
}

void _write(Map<String, dynamic> target, String key, Object? value) {
  if (value == null || value is String && value.trim().isEmpty) {
    target.remove(key);
  } else if (value is List && value.isEmpty) {
    target.remove(key);
  } else {
    target[key] = value;
  }
}

String? _optional(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String? _text(Object? value) => value?.toString().trim().letEmptyToNull();

int? _integer(Object? value) => value is num
    ? value.toInt()
    : int.tryParse(value?.toString() ?? '');

List<String> _stringList(Object? value) => value is List
    ? [for (final entry in value) if (_text(entry) case final text?) text]
    : const [];

String? _seriesText(Object? value) => value is Map
    ? _text(value['series_title']) ?? _text(value['title'])
    : _text(value);

extension on String? {
  String? letEmptyToNull() {
    final value = this;
    return value == null || value.isEmpty ? null : value;
  }
}
