import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';

BoardGameCatalogFormValues boardGameCatalogFormValuesFromMetadata(
  BoardGameMetadata metadata,
) {
  return BoardGameCatalogFormValues(
    title: metadata.title,
    originalTitle: metadata.originalTitle ?? '',
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
  final releaseDate = values.releaseDate == null
      ? null
      : PartialDate.fromDateTime(values.releaseDate!);
  return BoardGameMetadata(
    title: title.trim(),
    sortKey: _optional(values.sortTitle),
    originalTitle: _optional(values.originalTitle),
    subtitle: _optional(values.subtitle),
    searchAliases: values.searchAliases,
    synopsis: _optional(values.description),
    country: _optional(values.country),
    coverImageUrl: _optional(values.coverImageUrl),
    designers: values.designers,
    artists: values.artists,
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

String? _optional(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
