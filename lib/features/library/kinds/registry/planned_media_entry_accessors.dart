part of 'planned_media_adapters.dart';

class PlannedMediaEntryAccessors {
  const PlannedMediaEntryAccessors({
    required this.series,
    required this.storyArc,
    required this.country,
    required this.language,
    required this.pageCount,
    required this.ageRating,
    required this.imprint,
    required this.creators,
    required this.characters,
    required this.storyArcs,
    required this.genres,
    required this.rawPlatforms,
    required this.keyComic,
    required this.rawOrSlabbed,
    required this.gradingCompany,
  });

  final String? Function(LibraryWorkspaceEntry entry) series;
  final String? Function(LibraryWorkspaceEntry entry) storyArc;
  final String? Function(LibraryWorkspaceEntry entry) country;
  final String? Function(LibraryWorkspaceEntry entry) language;
  final int? Function(LibraryWorkspaceEntry entry) pageCount;
  final String? Function(LibraryWorkspaceEntry entry) ageRating;
  final String? Function(LibraryWorkspaceEntry entry) imprint;
  final List<Map<String, dynamic>>? Function(LibraryWorkspaceEntry entry)
      creators;
  final List<String>? Function(LibraryWorkspaceEntry entry) characters;
  final List<String>? Function(LibraryWorkspaceEntry entry) storyArcs;
  final List<String>? Function(LibraryWorkspaceEntry entry) genres;
  final List<String>? Function(LibraryWorkspaceEntry entry) rawPlatforms;
  final bool Function(LibraryWorkspaceEntry entry) keyComic;
  final String? Function(LibraryWorkspaceEntry entry) rawOrSlabbed;
  final String? Function(LibraryWorkspaceEntry entry) gradingCompany;
}

final plannedDefaultEntryAccessors = PlannedMediaEntryAccessors(
  series: (entry) => entry.series?.seriesTitle,
  storyArc: (entry) => _firstStringValue(entry.storyArcs),
  country: (entry) => entry.country,
  language: (entry) => entry.language,
  pageCount: (entry) => entry.publishing?.pageCount,
  ageRating: (entry) => entry.ageRating,
  imprint: (entry) => entry.publishing?.imprint,
  creators: (entry) => entry.creators,
  characters: (entry) => entry.characters,
  storyArcs: (entry) => entry.storyArcs,
  genres: (entry) => entry.genres,
  rawPlatforms: (entry) => entry.game?.platforms ?? entry.rawPlatforms,
  keyComic: (_) => false,
  rawOrSlabbed: (_) => null,
  gradingCompany: (_) => null,
);

final plannedComicEntryAccessors = PlannedMediaEntryAccessors(
  series: (entry) => entry.series?.seriesTitle,
  storyArc: (entry) => _firstStringValue(entry.storyArcs),
  country: (entry) => entry.country,
  language: (entry) => entry.language,
  pageCount: (entry) => entry.publishing?.pageCount,
  ageRating: (entry) => entry.ageRating,
  imprint: (entry) => entry.publishing?.imprint,
  creators: (entry) => entry.creators,
  characters: (entry) => entry.characters,
  storyArcs: (entry) => entry.storyArcs,
  genres: (entry) => entry.genres,
  rawPlatforms: (entry) => entry.game?.platforms ?? entry.rawPlatforms,
  keyComic: (entry) => entry.comic?.keyComic ?? false,
  rawOrSlabbed: (entry) => entry.comic?.rawOrSlabbed,
  gradingCompany: (entry) => entry.comic?.gradingCompany,
);

final plannedBookEntryAccessors = plannedDefaultEntryAccessors;
final plannedGameEntryAccessors = plannedDefaultEntryAccessors;
final plannedBoardGameEntryAccessors = plannedDefaultEntryAccessors;
final plannedMovieEntryAccessors = plannedDefaultEntryAccessors;
final plannedMusicEntryAccessors = plannedDefaultEntryAccessors;

LibraryEntryFilterValues plannedMediaFilterValuesForEntry(
  LibraryWorkspaceEntry entry,
  PlannedMediaEntryAccessors accessors,
) {
  return LibraryEntryFilterValues(
    series: _trimmedOrNull(entry.series?.seriesTitle),
    country: _trimmedOrNull(accessors.country(entry)),
    language: _trimmedOrNull(accessors.language(entry)),
  );
}

Iterable<String> plannedMediaLinkedMetadataCandidatesForEntry(
  LibraryWorkspaceEntry entry,
  PlannedMediaEntryAccessors accessors,
) sync* {
  final filterValues = plannedMediaFilterValuesForEntry(entry, accessors);
  final publishing = entry.publishing;
  yield* _nonEmptyValues([
    entry.resolvedTitle,
    entry.title,
    entry.localizedTitle,
    entry.originalTitle,
    filterValues.series,
    entry.itemNumber,
    entry.publisher,
    entry.variant,
    publishing?.imprint,
    publishing?.seriesGroup,
    filterValues.country,
    filterValues.language,
    accessors.ageRating(entry),
  ]);
  yield* _nonEmptyValues(entry.searchAliases);
  if (accessors.creators(entry) case final creators?) {
    for (final credit in creators) {
      final name = credit['name']?.toString();
      if (name != null && name.trim().isNotEmpty) {
        yield name.trim();
      }
    }
  }
  yield* _nonEmptyValues(accessors.characters(entry));
  yield* _nonEmptyValues(accessors.storyArcs(entry));
  yield* _nonEmptyValues(accessors.genres(entry));
  if (accessors.rawPlatforms(entry) case final platforms?) {
    yield* _nonEmptyValues(platforms);
  }
}

String? plannedMediaSubgroupKeyForEntry(
  LibraryWorkspaceEntry entry,
  LibraryGroupMode groupMode,
) {
  if (groupMode != LibraryGroupMode.series) {
    return null;
  }
  if (entry.mediaType.trim().toLowerCase() == 'book') {
    return null;
  }
  final series = entry.series;
  if (series?.seasonNumber != null) {
    return 'Season ${series!.seasonNumber}';
  }
  if (series?.volumeName != null && series!.volumeName!.trim().isNotEmpty) {
    return series.volumeName!.trim();
  }
  if (series?.volumeNumber != null) {
    return libraryVolumeLabel(series!.volumeNumber);
  }
  return null;
}

int plannedMediaCompareSubgroupKeys(
  String left,
  String right,
  LibraryGroupMode groupMode,
) {
  if (groupMode != LibraryGroupMode.series) {
    return left.compareTo(right);
  }
  final leftNumber = _extractSubgroupNumber(left);
  final rightNumber = _extractSubgroupNumber(right);
  if (leftNumber != null && rightNumber != null) {
    return leftNumber.compareTo(rightNumber);
  }
  return left.compareTo(right);
}
