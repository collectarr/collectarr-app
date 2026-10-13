import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';
import 'package:collectarr_app/core/models/partial_date.dart';

GameCatalogFormValues gameCatalogFormValuesFromMetadata(
  GameCatalogMetadata metadata,
) {
  return GameCatalogFormValues(
    title: metadata.title,
    displayTitle: metadata.displayTitle ?? '',
    originalTitle: metadata.originalTitle ?? '',
    localizedTitle: metadata.localizedTitle ?? '',
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
    region: metadata.releaseRegion ?? '',
    format: metadata.physicalFormatLabel ?? metadata.physicalFormat ?? '',
    physicalFormatId: metadata.physicalFormat,
    releaseDate: metadata.releaseDate,
    releaseYear: metadata.releaseDateParts?.year,
    catalogNumber: metadata.catalogNumber ?? '',
    releaseStatus: metadata.releaseStatus ?? '',
    language: metadata.languages.firstOrNull ?? '',
    barcode: metadata.barcode ?? '',
    coverImageUrl: metadata.coverImageUrl ?? '',
    variant: metadata.variantName ?? '',
    thumbnailImageUrl: metadata.thumbnailImageUrl ?? '',
  );
}

GameCatalogMetadata gameMetadataFromManualFormValues({
  required GameCatalogFormValues values,
  required String id,
  required String title,
  List<GameCatalogLink> externalLinks = const [],
}) {
  final releaseDate = _effectiveReleaseDate(values);
  final publisher = _optional(values.publisher);
  final languages = values.languages.isNotEmpty
      ? values.languages
      : [_optional(values.language)].whereType<String>().toList();
  final raw = <String, dynamic>{
    'id': id,
    'kind': 'game',
    'title': title.trim(),
    if (_optional(values.sortTitle) case final value?) 'sort_key': value,
    if (_optional(values.subtitle) case final value?) 'subtitle': value,
    if (_optional(values.displayTitle) case final value?)
      'display_title': value,
    if (_optional(values.originalTitle) case final value?)
      'original_title': value,
    if (_optional(values.localizedTitle) case final value?)
      'localized_title': value,
    if (_optional(values.description) case final value?) 'description': value,
    if (_optional(values.description) case final value?) 'synopsis': value,
    if (_optional(values.editionTitle) case final value?)
      'edition_title': value,
    'platforms': values.platforms,
    if (_optional(values.region) case final value?) 'release_region': value,
    if (releaseDate case final value?) 'release_date': value.toIso8601String(),
    if (publisher != null) 'publisher': publisher,
    if (languages.isNotEmpty) 'languages': languages,
    if (_optional(values.barcode) case final value?) 'barcode': value,
    if (_optional(values.variant) case final value?) 'variant_name': value,
    if (_optional(values.catalogNumber) case final value?)
      'catalog_number': value,
    if (_optional(values.physicalFormatId ?? values.format) case final value?)
      'physical_format': value,
    if (_optional(values.format) case final value?)
      'physical_format_label': value,
    if (_optional(values.coverImageUrl) case final value?)
      'cover_image_url': value,
    if (_optional(values.thumbnailImageUrl) case final value?)
      'thumbnail_image_url': value,
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
    if (externalLinks.isNotEmpty)
      'external_links': [for (final link in externalLinks) link.toJson()],
    if (values.searchAliases.isNotEmpty) 'search_aliases': values.searchAliases,
  };
  return GameCatalogMetadata.fromJson(raw);
}

GameCatalogMetadata applyGameCatalogFormValues({
  required GameCatalogMetadata current,
  required GameCatalogFormValues values,
  required String title,
}) {
  final originalPlot = current.synopsis ?? current.description ?? '';
  final plotChanged = values.description != originalPlot;
  final releaseDateParts = _releaseDateParts(current, values);
  final preservedCredits = current.creators
      .where((credit) => !_isDeveloperRole(credit.role))
      .toList(growable: false);
  final credits = [
    ...preservedCredits,
    for (var index = 0; index < values.developers.length; index++)
      GameCatalogPersonCredit(
        name: values.developers[index],
        role: 'Developer',
        sequence: index,
      ),
  ];
  final payload = current.toJson()
    ..addAll({
      'title': title.trim(),
      'sort_key': _optional(values.sortTitle),
      'display_title': _optional(values.displayTitle),
      'original_title': _optional(values.originalTitle),
      'localized_title': _optional(values.localizedTitle),
      'subtitle': _optional(values.subtitle),
      'search_aliases': values.searchAliases,
      if (plotChanged) 'synopsis': _optional(values.description),
      if (plotChanged) 'description': _optional(values.description),
      'age_rating': values.ageRatings.firstOrNull,
      'barcode': _optional(values.barcode),
      'catalog_number': _optional(values.catalogNumber),
      'company_roles': values.companyRoles,
      'country': _optional(values.country) ?? current.country,
      'cover_image_url': _optional(values.coverImageUrl),
      'thumbnail_image_url': _optional(values.thumbnailImageUrl),
      'developers': values.developers,
      'edition_title': _optional(values.editionTitle),
      'genres': values.genres,
      'identifiers': values.identifiers,
      'language': values.languages.firstOrNull,
      'languages': values.languages,
      'original_language': _optional(values.originalLanguage),
      'physical_format': _optional(values.physicalFormatId ?? values.format),
      'physical_format_label': _optional(values.format),
      'platforms': values.platforms,
      'publisher': _optional(values.publisher),
      'release_date': releaseDateParts?.isoString,
      'release_date_parts': releaseDateParts?.toJson(),
      'release_region': _optional(values.region),
      'release_status': _optional(values.releaseStatus),
      'series_title': _optional(values.series),
      'variant_name': _optional(values.variant),
      'toy_subtype': _optional(values.toySubtype),
      'toy_type': _optional(values.toyType),
      'creators': [for (final credit in credits) credit.toJson()],
    });
  return GameCatalogMetadata.fromJson(payload);
}

PartialDate? _releaseDateParts(
  GameCatalogMetadata current,
  GameCatalogFormValues values,
) {
  final selectedDate = values.releaseDate;
  final year = values.releaseYear;
  if (selectedDate == null && year == null) return null;

  final original = current.releaseDateParts;
  if (original != null &&
      selectedDate != null &&
      selectedDate.year == original.year &&
      (original.month == null || selectedDate.month == original.month) &&
      (original.day == null || selectedDate.day == original.day) &&
      (year == null || year == original.year)) {
    return original;
  }
  if (selectedDate == null) {
    return year == null ? null : PartialDate(year: year);
  }
  if (year != null && year != selectedDate.year) {
    return PartialDate.fromDateTime(
      DateTime.utc(year, selectedDate.month, selectedDate.day),
    );
  }
  return PartialDate.fromDateTime(selectedDate);
}

bool _isDeveloperRole(String? role) =>
    role?.toLowerCase().contains('developer') ?? false;

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
