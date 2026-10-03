import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';

BoardGameCatalogFormValues boardGameCatalogFormValuesFromMetadata(
  BoardGameMetadata metadata,
) {
  final raw = metadata.rawPayload;
  return BoardGameCatalogFormValues(
    title: metadata.title,
    originalTitle: metadata.originalTitle ?? '',
    sortTitle: metadata.sortKey ?? '',
    subtitle: _text(raw['subtitle']) ?? '',
    description: metadata.synopsis ?? '',
    originalLanguage: _text(raw['original_language']) ?? '',
    publisher: metadata.publisher ?? metadata.publishers.firstOrNull ?? '',
    platforms: _strings(raw['platforms']),
    identifiers: _strings(raw['identifiers']),
    contributors: _strings(raw['contributors']),
    designers: metadata.designers,
    artists: metadata.artists,
    characters: _strings(raw['characters']),
    mechanics: metadata.mechanics,
    categories: metadata.categories,
    families: metadata.families,
    themes: metadata.themes,
    expansions: metadata.expansions,
    expansionFor: metadata.expansionFor ?? '',
    rankings: _strings(raw['rankings']),
    searchAliases: _strings(raw['search_aliases']),
    languages: metadata.languages,
    yearPublished: metadata.yearPublished,
    minPlayers: metadata.minPlayers,
    maxPlayers: metadata.maxPlayers,
    recommendedPlayers: metadata.recommendedPlayers ?? '',
    bestPlayers: metadata.bestPlayers ?? '',
    minPlaytimeMinutes: metadata.minPlaytimeMinutes,
    maxPlaytimeMinutes: metadata.maxPlaytimeMinutes,
    minimumAge: metadata.minimumAge,
    complexityWeight: metadata.complexityWeight,
    bggRating: metadata.bggRating,
    bggRatingCount: metadata.bggRatingCount,
    bggRank: metadata.bggRank,
    seriesTitle: metadata.seriesTitle ?? '',
    itemNumber: metadata.itemNumber ?? '',
    variant: metadata.variant ?? '',
    ageRating: _text(raw['age_rating']) ?? '',
    audienceRating: _text(raw['audience_rating']) ?? '',
    barcode: metadata.barcode ?? '',
    catalogNumber: _text(raw['catalog_number']) ?? '',
    country: _text(raw['country']) ?? '',
    coverImageUrl: _text(raw['cover_image_url']) ?? '',
    format: metadata.physicalFormatLabel ?? metadata.physicalFormat ?? '',
    language: metadata.languages.firstOrNull ?? _text(raw['language']) ?? '',
    playingTimeMinutes: _integer(raw['playing_time_minutes']),
    releaseDate: _date(raw['release_date']),
    releaseStatus: _text(raw['release_status']) ?? '',
  );
}

BoardGameMetadata boardGameMetadataFromManualFormValues({
  required BoardGameCatalogFormValues values,
  required String id,
  required String title,
}) {
  final publisher = _optional(values.publisher);
  final language = _optional(values.language);
  final languages = values.languages.isEmpty
      ? [if (language != null) language]
      : values.languages;
  return BoardGameMetadata.fromJson({
    'id': id,
    'kind': 'boardgame',
    'title': title.trim(),
    if (_optional(values.originalTitle) case final value?)
      'original_title': value,
    if (_optional(values.sortTitle) case final value?) 'sort_key': value,
    if (_optional(values.subtitle) case final value?) 'subtitle': value,
    if (_optional(values.description) case final value?) 'synopsis': value,
    if (_optional(values.originalLanguage) case final value?)
      'original_language': value,
    if (publisher != null) 'publisher': publisher,
    if (publisher != null) 'publishers': [publisher],
    if (values.platforms.isNotEmpty) 'platforms': values.platforms,
    if (values.identifiers.isNotEmpty) 'identifiers': values.identifiers,
    if (values.contributors.isNotEmpty) 'contributors': values.contributors,
    if (values.designers.isNotEmpty) 'designers': values.designers,
    if (values.artists.isNotEmpty) 'artists': values.artists,
    if (values.characters.isNotEmpty) 'characters': values.characters,
    if (values.mechanics.isNotEmpty) 'mechanics': values.mechanics,
    if (values.categories.isNotEmpty) 'categories': values.categories,
    if (values.families.isNotEmpty) 'families': values.families,
    if (values.themes.isNotEmpty) 'themes': values.themes,
    if (values.expansions.isNotEmpty) 'expansions': values.expansions,
    if (_optional(values.expansionFor) case final value?)
      'expansion_for': value,
    if (values.rankings.isNotEmpty) 'rankings': values.rankings,
    if (values.searchAliases.isNotEmpty) 'search_aliases': values.searchAliases,
    if (languages.isNotEmpty) 'languages': languages,
    if (language != null) 'language': language,
    if (values.yearPublished != null) 'year_published': values.yearPublished,
    if (values.minPlayers != null) 'min_players': values.minPlayers,
    if (values.maxPlayers != null) 'max_players': values.maxPlayers,
    if (_optional(values.recommendedPlayers) case final value?)
      'recommended_players': value,
    if (_optional(values.bestPlayers) case final value?) 'best_players': value,
    if (values.minPlaytimeMinutes != null)
      'min_playtime_minutes': values.minPlaytimeMinutes,
    if (values.maxPlaytimeMinutes != null)
      'max_playtime_minutes': values.maxPlaytimeMinutes,
    if (values.minimumAge != null) 'min_age': values.minimumAge,
    if (values.complexityWeight != null)
      'complexity_weight': values.complexityWeight,
    if (values.bggRating != null) 'bgg_rating': values.bggRating,
    if (values.bggRatingCount != null)
      'bgg_rating_count': values.bggRatingCount,
    if (values.bggRank != null) 'bgg_rank': values.bggRank,
    if (_optional(values.seriesTitle) case final value?) 'series_title': value,
    if (_optional(values.itemNumber) case final value?) 'item_number': value,
    if (_optional(values.format) case final value?) ...{
      'physical_format': value,
      'physical_format_label': value,
    },
    if (_optional(values.barcode) case final value?) 'barcode': value,
    if (_optional(values.variant) case final value?) 'variant_name': value,
    if (_optional(values.ageRating) case final value?) 'age_rating': value,
    if (_optional(values.audienceRating) case final value?)
      'audience_rating': value,
    if (_optional(values.catalogNumber) case final value?)
      'catalog_number': value,
    if (_optional(values.country) case final value?) 'country': value,
    if (_optional(values.coverImageUrl) case final value?)
      'cover_image_url': value,
    if (values.playingTimeMinutes != null)
      'playing_time_minutes': values.playingTimeMinutes,
    if (values.releaseDate case final value?)
      'release_date': value.toIso8601String(),
    if (_optional(values.releaseStatus) case final value?)
      'release_status': value,
  });
}

String? _optional(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String? _text(Object? value) => _optional(value?.toString() ?? '');

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

int? _integer(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');

List<String> _strings(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (_text(entry) case final text?) text
      ]
    : const [];
