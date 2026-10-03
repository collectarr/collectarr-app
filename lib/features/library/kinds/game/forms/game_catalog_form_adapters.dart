import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';

GameCatalogFormValues gameCatalogFormValuesFromMetadata(
  GameCatalogMetadata metadata,
) {
  return GameCatalogFormValues(
    title: metadata.title,
    sortTitle: metadata.sortKey ?? '',
    subtitle: metadata.subtitle ?? '',
    description: metadata.synopsis ?? metadata.description ?? '',
    publisher: metadata.publisher ?? '',
    platforms: metadata.platforms,
    identifiers: metadata.identifiers.map((value) => value.value).toList(),
    companyRoles: metadata.companyRoles,
    developers: metadata.developers,
    ageRatings: [if (metadata.ageRating case final value?) value],
    genres: metadata.genres,
    searchAliases: metadata.searchAliases,
    originalLanguage: metadata.originalLanguage ?? '',
    franchise: metadata.franchise ?? '',
    toySubtype: metadata.toySubtype ?? '',
    toyType: metadata.toyType ?? '',
    series: metadata.seriesTitle ?? '',
    languages: metadata.languages,
    country: metadata.country,
    editionTitle: metadata.editionTitle ?? '',
    platform: metadata.platforms.firstOrNull ?? '',
    region: metadata.releaseRegion ?? '',
    format: metadata.physicalFormat ?? '',
    releaseDate: metadata.releaseDate,
    catalogNumber: metadata.catalogNumber ?? '',
    releaseStatus: metadata.releaseStatus ?? '',
    language: metadata.languages.firstOrNull ?? '',
    barcode: metadata.barcode ?? '',
    coverImageUrl: metadata.coverImageUrl ?? '',
    variant: metadata.variantName ?? '',
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
    if (languages.isNotEmpty) 'languages': languages,
    if (_optional(values.barcode) case final value?) 'barcode': value,
    if (_optional(values.variant) case final value?) 'variant_name': value,
    if (_optional(values.catalogNumber) case final value?)
      'catalog_number': value,
    if (_optional(values.format) case final value?) 'physical_format': value,
    if (_optional(values.coverImageUrl) case final value?)
      'cover_image_url': value,
    if (values.developers.isNotEmpty) 'developers': values.developers,
    if (_optional(values.franchise) case final value?) 'franchise': value,
    if (_optional(values.toySubtype) case final value?) 'toy_subtype': value,
    if (_optional(values.toyType) case final value?) 'toy_type': value,
    if (_optional(values.series) case final value?) 'series_title': value,
    if (values.genres.isNotEmpty) 'genres': values.genres,
    if (values.ageRatings.firstOrNull case final value?) 'age_rating': value,
    if (languages.firstOrNull case final value?) 'language': value,
    if (_optional(values.country) case final value?) 'country': value,
    if (_optional(values.originalLanguage) case final value?)
      'original_language': value,
    if (values.identifiers.isNotEmpty) 'identifiers': values.identifiers,
    if (values.companyRoles.isNotEmpty) 'company_roles': values.companyRoles,
    if (values.searchAliases.isNotEmpty) 'search_aliases': values.searchAliases,
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
