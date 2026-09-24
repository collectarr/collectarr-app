import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_edition.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';

BoardGameCatalogFormValues boardGameCatalogFormValuesFromMedia(
  BoardGameMedia media,
) {
  final raw = media.rawPayload;
  return BoardGameCatalogFormValues(
    title: media.title,
    originalTitle: _text(raw['original_title']) ?? '',
    sortTitle: media.sortTitle ?? '',
    subtitle: media.subtitle ?? '',
    description: media.description ?? '',
    originalLanguage: media.originalLanguage ?? '',
    workReleaseDate: media.releaseDate,
    publisher: media.publisher ?? '',
    platforms: media.platforms,
    identifiers: media.identifiers,
    contributors: media.contributors,
    designers: _strings(raw['designers']),
    artists: _strings(raw['artists']),
    characters: _strings(raw['characters']),
    mechanics: media.mechanics,
    categories: media.categories,
    families: media.families,
    themes: _strings(raw['themes']),
    expansions: media.expansions,
    expansionFor: _text(raw['expansion_for']) ?? '',
    rankings: media.rankings,
    searchAliases: media.searchAliases,
    languages: _strings(raw['languages']),
    yearPublished: _integer(raw['year_published']),
    minPlayers: _integer(raw['min_players']),
    maxPlayers: _integer(raw['max_players']),
    recommendedPlayers: _text(raw['recommended_players']) ?? '',
    bestPlayers: _text(raw['best_players']) ?? '',
    minPlaytimeMinutes: _integer(raw['min_playtime_minutes']),
    maxPlaytimeMinutes: _integer(raw['max_playtime_minutes']),
    minimumAge: _integer(raw['minimum_age']) ?? _integer(raw['min_age']),
    complexityWeight: _decimal(raw['complexity_weight']) ??
        _decimal(raw['weight']),
    bggRating: _decimal(raw['bgg_rating']) ?? _decimal(raw['rating']),
    bggRatingCount: _integer(raw['bgg_rating_count']) ??
        _integer(raw['rating_count']),
    bggRank: _integer(raw['bgg_rank']) ?? _integer(raw['rank']),
    seriesTitle: _text(raw['series_title']) ?? '',
    itemNumber: _text(raw['item_number']) ?? '',
  );
}

BoardGameCatalogFormValues boardGameCatalogFormValuesFromEdition(
  BoardGameEdition edition,
) =>
    BoardGameCatalogFormValues(
      releaseTitle: edition.titleValue ?? edition.title,
      editionTitle: edition.editionTitle ?? '',
      variant: _text(edition.rawPayload['variant']) ?? '',
      ageRating: edition.ageRating ?? '',
      audienceRating: edition.audienceRating ?? '',
      barcode: edition.barcode ?? '',
      catalogNumber: edition.catalogNumber ?? '',
      country: edition.country ?? '',
      coverImageUrl: edition.coverImageUrl ?? '',
      backCoverImageUrl: _text(edition.rawPayload['back_cover_image_url']) ?? '',
      editionDescription: edition.description ?? '',
      format: edition.format ?? '',
      language: edition.language ?? '',
      editionMaxPlayers: edition.maxPlayers,
      editionMinAge: edition.minAge,
      editionMinPlayers: edition.minPlayers,
      playingTimeMinutes: edition.playingTimeMinutes,
      editionPublisher: edition.publisher ?? '',
      releaseDate: edition.releaseDate,
      releaseStatus: edition.releaseStatus ?? '',
    );

BoardGameMedia boardGameMediaFromCatalogFormValues({
  required BoardGameMedia original,
  required BoardGameCatalogFormValues values,
}) {
  final raw = _withoutKeys(original.rawPayload, const {
    'id',
    'kind',
    'title',
    'original_title',
    'sort_title',
    'subtitle',
    'description',
    'synopsis',
    'release_date',
    'original_language',
    'publisher',
    'platforms',
    'identifiers',
    'contributors',
    'mechanics',
    'categories',
    'families',
    'expansions',
    'rankings',
    'search_aliases',
  });
  _write(raw, 'original_title', values.originalTitle);
  _write(raw, 'designers', values.designers);
  _write(raw, 'artists', values.artists);
  _write(raw, 'characters', values.characters);
  _write(raw, 'themes', values.themes);
  _write(raw, 'expansion_for', values.expansionFor);
  _write(raw, 'languages', values.languages);
  _write(raw, 'year_published', values.yearPublished);
  _write(raw, 'min_players', values.minPlayers);
  _write(raw, 'max_players', values.maxPlayers);
  _write(raw, 'recommended_players', values.recommendedPlayers);
  _write(raw, 'best_players', values.bestPlayers);
  _write(raw, 'min_playtime_minutes', values.minPlaytimeMinutes);
  _write(raw, 'max_playtime_minutes', values.maxPlaytimeMinutes);
  _write(raw, 'minimum_age', values.minimumAge);
  _write(raw, 'complexity_weight', values.complexityWeight);
  _write(raw, 'bgg_rating', values.bggRating);
  _write(raw, 'bgg_rating_count', values.bggRatingCount);
  _write(raw, 'bgg_rank', values.bggRank);
  _write(raw, 'series_title', values.seriesTitle);
  _write(raw, 'item_number', values.itemNumber);
  return BoardGameMedia(
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
    contributors: List<String>.unmodifiable(values.contributors),
    mechanics: List<String>.unmodifiable(values.mechanics),
    categories: List<String>.unmodifiable(values.categories),
    families: List<String>.unmodifiable(values.families),
    expansions: List<String>.unmodifiable(values.expansions),
    rankings: List<String>.unmodifiable(values.rankings),
    searchAliases: List<String>.unmodifiable(values.searchAliases),
    editions: original.editions,
    rawPayload: raw,
  );
}

BoardGameEdition boardGameEditionFromCatalogFormValues({
  required BoardGameEdition original,
  required BoardGameCatalogFormValues values,
}) {
  final raw = _withoutKeys(original.rawPayload, const {
    'id',
    'kind',
    'work_id',
    'title',
    'title_value',
    'edition_title',
    'age_rating',
    'audience_rating',
    'barcode',
    'upc',
    'isbn',
    'catalog_number',
    'country',
    'region',
    'cover_image_url',
    'back_cover_image_url',
    'description',
    'synopsis',
    'format',
    'physical_format',
    'language',
    'max_players',
    'min_age',
    'minimum_age',
    'min_players',
    'playing_time_minutes',
    'publisher',
    'release_date',
    'release_status',
    'variant',
  });
  _write(raw, 'variant', values.variant);
  _write(raw, 'back_cover_image_url', values.backCoverImageUrl);
  return BoardGameEdition(
    id: original.id,
    title: _optional(values.releaseTitle) ?? original.title,
    titleValue: _optional(values.releaseTitle),
    workId: original.workId,
    editionTitle: _optional(values.editionTitle),
    ageRating: _optional(values.ageRating),
    audienceRating: _optional(values.audienceRating),
    barcode: _optional(values.barcode),
    catalogNumber: _optional(values.catalogNumber),
    country: _optional(values.country),
    coverImageUrl: _optional(values.coverImageUrl),
    description: _optional(values.editionDescription),
    format: _optional(values.format),
    language: _optional(values.language),
    maxPlayers: values.editionMaxPlayers,
    minAge: values.editionMinAge,
    minPlayers: values.editionMinPlayers,
    playingTimeMinutes: values.playingTimeMinutes,
    publisher: _optional(values.editionPublisher),
    releaseDate: values.releaseDate,
    releaseStatus: _optional(values.releaseStatus),
    rawPayload: raw,
  );
}

BoardGameMedia boardGameMediaWithEdition(
  BoardGameMedia original,
  BoardGameEdition edition,
) {
  final editions = [
    for (final current in original.editions)
      current.id == edition.id ? edition : current,
  ];
  return BoardGameMedia(
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
    contributors: original.contributors,
    mechanics: original.mechanics,
    categories: original.categories,
    families: original.families,
    expansions: original.expansions,
    rankings: original.rankings,
    searchAliases: original.searchAliases,
    editions: editions,
    rawPayload: {
      ...original.rawPayload,
      'editions': [for (final entry in editions) entry.toJson()],
    },
  );
}

BoardGameMetadata boardGameMetadataFromManualFormValues({
  required BoardGameCatalogFormValues values,
  required String id,
  required String title,
}) =>
    BoardGameMetadata.fromJson({
      'id': id,
      'title': title.trim(),
      'original_title': _optional(values.originalTitle),
      'synopsis': _optional(values.description),
      'year_published': values.yearPublished,
      'min_players': values.minPlayers,
      'max_players': values.maxPlayers,
      'recommended_players': _optional(values.recommendedPlayers),
      'best_players': _optional(values.bestPlayers),
      'min_playtime_minutes': values.minPlaytimeMinutes,
      'max_playtime_minutes': values.maxPlaytimeMinutes,
      'minimum_age': values.minimumAge,
      'complexity_weight': values.complexityWeight,
      'designers': values.designers,
      'artists': values.artists,
      'publisher': _optional(values.editionPublisher),
      'publishers':
          [_optional(values.editionPublisher)].whereType<String>().toList(),
      'mechanics': values.mechanics,
      'categories': values.categories,
      'families': values.families,
      'themes': values.themes,
      'expansions': values.expansions,
      'expansion_for': _optional(values.expansionFor),
      'languages': values.languages,
      'series_title': _optional(values.seriesTitle),
      'item_number': _optional(values.itemNumber),
      'physical_format_label': _optional(values.format),
      'barcode': _optional(values.barcode),
      'variant': _optional(values.variant),
      'characters': values.characters,
      'edition_title': _optional(values.editionTitle),
      'country': _optional(values.country),
      'cover_image_url': _optional(values.coverImageUrl),
      'back_cover_image_url': _optional(values.backCoverImageUrl),
      'release_date': values.releaseDate?.toIso8601String(),
      'catalog_number': _optional(values.catalogNumber),
      'language': _optional(values.language),
      'format': _optional(values.format),
      'age_rating': _optional(values.ageRating),
      'audience_rating': _optional(values.audienceRating),
      'release_status': _optional(values.releaseStatus),
      'edition_min_players': values.editionMinPlayers,
      'edition_max_players': values.editionMaxPlayers,
      'edition_min_age': values.editionMinAge,
      'playing_time_minutes': values.playingTimeMinutes,
    });

Map<String, dynamic> _withoutKeys(
  Map<String, dynamic> source,
  Set<String> keys,
) =>
    {
      for (final entry in source.entries)
        if (!keys.contains(entry.key)) entry.key: entry.value,
    };

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

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _integer(Object? value) => value is num
    ? value.toInt()
    : int.tryParse(value?.toString() ?? '');

double? _decimal(Object? value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '');

List<String> _strings(Object? value) => value is List
    ? [for (final entry in value) if (_text(entry) case final text?) text]
    : const [];
