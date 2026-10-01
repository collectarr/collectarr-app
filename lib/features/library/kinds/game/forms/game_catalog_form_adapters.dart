import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';

GameCatalogFormValues gameCatalogFormValuesFromMetadata(
  GameCatalogMetadata metadata,
) {
  final raw = metadata.rawPayload;
  return GameCatalogFormValues(
    title: metadata.title,
    sortTitle: _text(raw['sort_key'] ?? raw['sort_title']) ?? '',
    subtitle: _text(raw['subtitle']) ?? '',
    description: metadata.synopsis ?? _text(raw['description']) ?? '',
    publisher: metadata.publishers.firstOrNull ?? '',
    platforms: metadata.platforms,
    identifiers: _stringList(raw['identifiers']),
    companyRoles: _stringList(raw['company_roles']),
    developers: metadata.developers,
    ageRatings: [if (metadata.ageRating case final value?) value],
    genres: metadata.genres,
    searchAliases: _stringList(raw['search_aliases']),
    originalLanguage: _text(raw['original_language']) ?? '',
    franchise: metadata.franchise ?? '',
    series: metadata.series ?? '',
    languages: metadata.languages,
    country: metadata.country,
    editionTitle: metadata.edition ?? '',
    platform: metadata.platform ?? metadata.platforms.firstOrNull ?? '',
    region: metadata.releaseRegion ?? '',
    format: metadata.physicalFormat ?? '',
    releaseDate: metadata.releaseDate,
    catalogNumber: _text(raw['catalog_number']) ?? '',
    releaseStatus: _text(raw['release_status']) ?? '',
    language: metadata.languages.firstOrNull ?? '',
    barcode: metadata.barcode ?? '',
    coverImageUrl: _text(raw['cover_image_url']) ?? '',
    variant: _text(raw['variant_name']) ?? '',
    backCoverImageUrl: '',
  );
}

GameCatalogMetadata gameMetadataFromManualFormValues({
  required GameCatalogFormValues values,
  required String id,
  required String title,
}) {
  final releaseDate = _effectiveReleaseDate(values);
  final publisher = _optional(values.publisher);
  final platform = _optional(values.platform);
  final languages = values.languages.isNotEmpty
      ? values.languages
      : [_optional(values.language)].whereType<String>().toList();
  final raw = <String, dynamic>{
    'id': id,
    'kind': 'game',
    'title': title.trim(),
    if (_optional(values.sortTitle) case final value?) 'sort_key': value,
    if (_optional(values.subtitle) case final value?) 'subtitle': value,
    if (_optional(values.description) case final value?) 'description': value,
    if (_optional(values.description) case final value?) 'synopsis': value,
    if (_optional(values.editionTitle) case final value?)
      'edition_title': value,
    if (values.platforms.isNotEmpty)
      'platforms': values.platforms
    else if (platform != null)
      'platforms': [platform],
    if (_optional(values.region) case final value?) 'release_region': value,
    if (releaseDate case final value?) 'release_date': value.toIso8601String(),
    if (publisher != null) 'publisher': publisher,
    if (_optional(values.barcode) case final value?) 'barcode': value,
    if (_optional(values.variant) case final value?) 'variant_name': value,
    if (_optional(values.catalogNumber) case final value?)
      'catalog_number': value,
    if (_optional(values.format) case final value?) 'physical_format': value,
    if (_optional(values.coverImageUrl) case final value?)
      'cover_image_url': value,
    if (values.developers.isNotEmpty) 'developers': values.developers,
    if (_optional(values.franchise) case final value?) 'franchise': value,
    if (_optional(values.series) case final value?) 'series_title': value,
    if (values.genres.isNotEmpty) 'genres': values.genres,
    if (values.ageRatings.firstOrNull case final value?) 'age_rating': value,
    if (languages.firstOrNull case final value?) 'language': value,
    if (_optional(values.country) case final value?) 'country': value,
    if (_optional(values.originalLanguage) case final value?)
      'original_language': value,
    if (values.identifiers.isNotEmpty) 'identifiers': values.identifiers,
    if (values.companyRoles.isNotEmpty) 'company_roles': values.companyRoles,
    if (values.searchAliases.isNotEmpty)
      'search_aliases': values.searchAliases,
  };
  return GameCatalogMetadata.fromJson(raw);
}

DateTime? _effectiveReleaseDate(GameCatalogFormValues values) {
  final year = values.releaseYear;
  final date = values.releaseDate;
  if (year == null || year < 1) return date;
  if (date == null) return DateTime.utc(year);
  return date.year == year ? date : DateTime.utc(year, date.month, date.day);
}

String? _optional(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String? _text(Object? value) => value?.toString().trim().letEmptyToNull();

List<String> _stringList(Object? value) => value is List
    ? [
        for (final entry in value)
          if (_text(entry) case final text?) text,
      ]
    : const [];

extension on String {
  String? letEmptyToNull() => isEmpty ? null : this;
}
