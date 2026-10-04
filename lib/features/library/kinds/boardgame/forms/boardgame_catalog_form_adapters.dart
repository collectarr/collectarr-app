import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';
import 'package:flutter/foundation.dart' show listEquals;

BoardGameCatalogFormValues boardGameCatalogFormValuesFromMetadata(
  BoardGameMetadata metadata,
) {
  return BoardGameCatalogFormValues(
    title: metadata.title,
    originalTitle: metadata.originalTitle ?? '',
    localizedTitle: metadata.localizedTitle ?? '',
    sortTitle: metadata.sortKey ?? '',
    subtitle: metadata.subtitle ?? '',
    description: metadata.synopsis ?? metadata.description ?? '',
    originalLanguage: metadata.originalLanguage ?? '',
    publisher: metadata.publisher ?? metadata.publishers.firstOrNull ?? '',
    platforms: metadata.platforms,
    identifiers: [
      for (final identifier in metadata.identifiers) identifier.value
    ],
    contributors: [for (final credit in metadata.contributors) credit.name],
    designers: metadata.designers,
    artists: metadata.artists,
    characters: [for (final character in metadata.characters) character.name],
    mechanics: metadata.mechanics,
    categories: metadata.categories,
    families: metadata.families,
    themes: metadata.themes,
    expansions: metadata.expansions,
    expansionFor: metadata.expansionFor ?? '',
    rankings: metadata.rankings,
    searchAliases: metadata.searchAliases,
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
    editionTitle: metadata.editionTitle ?? '',
    itemNumber: metadata.itemNumber ?? '',
    variant: metadata.variantName ?? '',
    ageRating: metadata.ageRating ?? '',
    audienceRating: metadata.audienceRating ?? '',
    barcode: metadata.barcode ?? '',
    catalogNumber: metadata.catalogNumber ?? '',
    country: metadata.country ?? '',
    coverImageUrl: metadata.coverImageUrl ?? '',
    format: metadata.physicalFormatLabel ?? metadata.physicalFormat ?? '',
    language: metadata.language ?? metadata.languages.firstOrNull ?? '',
    playingTimeMinutes: metadata.playingTimeMinutes,
    releaseDate: metadata.releaseDate?.asDateTime ??
        metadata.releaseDateParts?.asDateTime,
    releaseDateParts: metadata.releaseDateParts ?? metadata.releaseDate,
    releaseStatus: metadata.releaseStatus ?? '',
  );
}

BoardGameMetadata boardGameMetadataFromManualFormValues({
  required BoardGameCatalogFormValues values,
  required String title,
  List<BoardGameLink> externalLinks = const [],
}) {
  final publisher = _optional(values.publisher);
  final language = _optional(values.language);
  final languages = values.languages.isEmpty
      ? [if (language != null) language]
      : values.languages;
  final format = _optional(values.format);
  final releaseDate = values.releaseDateParts ??
      (values.releaseDate == null
          ? null
          : PartialDate.fromDateTime(values.releaseDate!));
  return BoardGameMetadata(
    title: title.trim(),
    sortKey: _optional(values.sortTitle),
    originalTitle: _optional(values.originalTitle),
    localizedTitle: _optional(values.localizedTitle),
    subtitle: _optional(values.subtitle),
    searchAliases: values.searchAliases,
    synopsis: _optional(values.description),
    country: _optional(values.country),
    coverImageUrl: _optional(values.coverImageUrl),
    designers: values.designers,
    artists: values.artists,
    editionTitle: _optional(values.editionTitle),
    expansions: values.expansions,
    externalLinks: externalLinks,
    families: values.families,
    identifiers: [
      for (final value in values.identifiers)
        if (_optional(value) case final normalized?)
          BoardGameIdentifier(identifierType: 'other', value: normalized),
    ],
    language: language,
    languages: languages,
    categories: values.categories,
    maxPlayers: values.maxPlayers,
    maxPlaytimeMinutes: values.maxPlaytimeMinutes,
    mechanics: values.mechanics,
    minimumAge: values.minimumAge,
    minPlayers: values.minPlayers,
    minPlaytimeMinutes: values.minPlaytimeMinutes,
    originalLanguage: _optional(values.originalLanguage),
    physicalFormat: format,
    physicalFormatLabel: format,
    platforms: values.platforms,
    playingTimeMinutes: values.playingTimeMinutes,
    publisher: publisher,
    publishers: [if (publisher != null) publisher],
    rankings: values.rankings,
    releaseDate: releaseDate,
    releaseDateParts: releaseDate,
    releaseStatus: _optional(values.releaseStatus),
    seriesTitle: _optional(values.seriesTitle),
    themes: values.themes,
    variantName: _optional(values.variant),
    yearPublished: values.yearPublished,
    recommendedPlayers: _optional(values.recommendedPlayers),
    bestPlayers: _optional(values.bestPlayers),
    complexityWeight: values.complexityWeight,
    bggRating: values.bggRating,
    bggRatingCount: values.bggRatingCount,
    bggRank: values.bggRank,
    contributors: [
      for (final value in values.contributors)
        if (_optional(value) case final normalized?)
          BoardGamePersonCredit(name: normalized),
    ],
    characters: [
      for (final value in values.characters)
        if (_optional(value) case final normalized?)
          BoardGameCharacter(name: normalized),
    ],
  );
}

BoardGameMetadata applyBoardGameCatalogFormValues({
  required BoardGameMetadata current,
  required BoardGameCatalogFormValues values,
  required String title,
}) {
  final publisher = _optional(values.publisher);
  final publishers = publisher == null ? <String>[] : [publisher];
  final releaseDate = values.releaseDateParts ??
      (values.releaseDate == null
          ? null
          : PartialDate.fromDateTime(values.releaseDate!));
  final currentPublishers = current.publishers.isNotEmpty
      ? current.publishers
      : [if (current.publisher case final value?) value];
  final descriptionChanged =
      values.description != (current.synopsis ?? current.description ?? '');
  final json = current.toJson()
    ..addAll({
      'title': title.trim(),
      'sort_key': _optional(values.sortTitle),
      'original_title': _optional(values.originalTitle),
      'localized_title': _optional(values.localizedTitle),
      'subtitle': _optional(values.subtitle),
      'search_aliases': values.searchAliases,
      if (descriptionChanged) 'synopsis': _optional(values.description),
      if (descriptionChanged && current.synopsis == null)
        'description': _optional(values.description),
      'country': _optional(values.country),
      'cover_image_url': _optional(values.coverImageUrl),
      'designers': values.designers,
      'artists': values.artists,
      'edition_title': _optional(values.editionTitle),
      'expansion_for': _optional(values.expansionFor),
      'expansions': values.expansions,
      'families': values.families,
      'categories': values.categories,
      'identifiers': [
        for (final identifier in _editedIdentifiers(
          values.identifiers,
          current.identifiers,
        ))
          identifier.toJson(),
      ],
      'language': _optional(values.language),
      'languages': values.languages,
      'max_players': values.maxPlayers,
      'max_playtime_minutes': values.maxPlaytimeMinutes,
      'mechanics': values.mechanics,
      'min_age': values.minimumAge,
      'min_players': values.minPlayers,
      'min_playtime_minutes': values.minPlaytimeMinutes,
      'original_language': _optional(values.originalLanguage),
      'physical_format': _optional(values.format),
      'physical_format_label': _optional(values.format),
      'platforms': values.platforms,
      'playing_time_minutes': values.playingTimeMinutes,
      'publisher': publisher,
      'publishers': publisher == currentPublishers.firstOrNull
          ? currentPublishers
          : publishers,
      'rankings': values.rankings,
      'release_date': releaseDate?.toJson(),
      'release_date_parts': releaseDate?.toJson(),
      'release_status': _optional(values.releaseStatus),
      'series_title': _optional(values.seriesTitle),
      'themes': values.themes,
      'variant_name': _optional(values.variant),
      'year_published': values.yearPublished,
      'recommended_players': _optional(values.recommendedPlayers),
      'best_players': _optional(values.bestPlayers),
      'complexity_weight': values.complexityWeight,
      'bgg_rating': values.bggRating,
      'bgg_rating_count': values.bggRatingCount,
      'bgg_rank': values.bggRank,
      'contributors': [
        for (final contributor in _editedContributors(
          values.contributors,
          current.contributors,
        ))
          contributor.toJson(),
      ],
      'characters': [
        for (final character in _editedCharacters(
          values.characters,
          current.characters,
        ))
          character.toJson(),
      ],
    });
  return BoardGameMetadata.fromJson(json);
}

List<BoardGameIdentifier> _editedIdentifiers(
  List<String> values,
  List<BoardGameIdentifier> existing,
) {
  final currentValues = existing.map((value) => value.value).toList();
  if (listEquals(values, currentValues)) return existing;
  final byValue = {
    for (final identifier in existing) identifier.value: identifier,
  };
  return [
    for (final value in values)
      if (value.trim().isNotEmpty)
        byValue[value] ??
            BoardGameIdentifier(identifierType: 'other', value: value),
  ];
}

List<BoardGamePersonCredit> _editedContributors(
  List<String> values,
  List<BoardGamePersonCredit> existing,
) {
  final byName = {for (final credit in existing) credit.name: credit};
  return [
    for (var index = 0; index < values.length; index++)
      if (values[index].trim().isNotEmpty)
        _creditForName(values[index].trim(), byName, index),
  ];
}

BoardGamePersonCredit _creditForName(
  String name,
  Map<String, BoardGamePersonCredit> existing,
  int sequence,
) {
  final credit = existing[name];
  if (credit == null) {
    return BoardGamePersonCredit(name: name, sequence: sequence);
  }
  return BoardGamePersonCredit(
    id: credit.id,
    personId: credit.personId,
    artistId: credit.artistId,
    name: credit.name,
    role: credit.role,
    roleId: credit.roleId,
    sequence: sequence,
    creditedName: credit.creditedName,
    joinPhrase: credit.joinPhrase,
    imageUrl: credit.imageUrl,
    sortName: credit.sortName,
    instrument: credit.instrument,
  );
}

List<BoardGameCharacter> _editedCharacters(
  List<String> values,
  List<BoardGameCharacter> existing,
) {
  final byName = {for (final character in existing) character.name: character};
  return [
    for (final name in values)
      if (name.trim().isNotEmpty)
        byName[name] ?? BoardGameCharacter(name: name.trim()),
  ];
}

String? _optional(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
