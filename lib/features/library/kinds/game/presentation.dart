import 'package:collectarr_app/core/models/catalog_item_types.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/game/game_domain.dart';
import 'package:collectarr_app/features/library/kinds/game/presentation_builder.dart';
import 'package:collectarr_app/features/library/shared/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_fields.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildGamesLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final item = source.catalogItem;
  if (item == null) {
    return buildGameWorkspaceEntry(
      GameWork(
        id: source.itemId,
        title: source.itemId,
      ),
      GamePersonalOverlay.fromShelfEntry(source),
    );
  }
  return buildGameWorkspaceEntry(
    _gameWorkFromMetadataItem(item),
    GamePersonalOverlay.fromShelfEntry(source),
  );
}

LibraryWorkspaceEntry buildGamesLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry as GameWorkspaceEntry;
  final release =
      _gameReleaseById(entry.gameReleases, request.referenceEditionId) ??
          _resolvePrimaryGameRelease(entry.gameReleases) ??
          GameRelease(
            id: request.referenceEditionId ?? entry.id,
            title: entry.variant ?? entry.title,
            platform: entry.game?.platforms.isNotEmpty == true
                ? entry.game!.platforms.first
                : null,
          );
  return buildGameReleaseWorkspaceEntry(
    titleEntry: entry,
    release: release,
    overlay: GamePersonalOverlay(
      updatedAt: request.updatedAt,
      isOwnedOverride: request.isOwned,
      isTrackedOverride: request.isTracked,
      isWishlistedOverride: request.isWishlisted,
    ),
  );
}

GameWork _gameWorkFromMetadataItem(LibraryMetadataItem item) {
  return GameWork(
    id: item.id,
    title: item.title,
    displayTitle: item.displayTitle,
    localizedTitle: item.localizedTitle,
    originalTitle: item.originalTitle,
    searchAliases: List<String>.unmodifiable(item.searchAliases ?? const []),
    itemNumber: item.itemNumber,
    synopsis: item.synopsis,
    coverImageUrl: item.coverImageUrl,
    thumbnailImageUrl: item.thumbnailImageUrl ?? item.coverImageUrl,
    publisher: item.publisher,
    coverDate: item.coverDate,
    releaseDate: item.releaseDate,
    releaseYear: item.releaseYear,
    barcode: item.barcode,
    variant: item.variant,
    crossover: item.crossover,
    platforms: List<String>.unmodifiable(item.game?.platforms ?? const []),
    identifiers: const <String>[],
    companyRoles: const <String>[],
    ageRatings: item.ageRating == null
        ? const <String>[]
        : List<String>.unmodifiable([item.ageRating!]),
    releases: [
      for (var index = 0; index < item.editions.length; index++)
        _gameReleaseFromCatalogEdition(
          item.editions[index],
          isPrimary: index == 0,
        ),
    ],
    trailerUrls: List<TrailerLink>.unmodifiable(item.trailerUrls),
    plotSummary: item.plotSummary,
    plotDescription: item.plotDescription,
    creators: item.creators == null
        ? null
        : List<Map<String, dynamic>>.unmodifiable(
            item.creators!
                .map((value) => Map<String, dynamic>.unmodifiable(value)),
          ),
    characters: List<String>.unmodifiable(item.characters ?? const <String>[]),
    storyArcs: List<String>.unmodifiable(item.storyArcs ?? const <String>[]),
    genres: List<String>.unmodifiable(item.genres ?? const <String>[]),
    country: item.country,
    language: item.language,
    ageRating: item.ageRating,
    audienceRating: item.audienceRating,
    physicalFormatLabel: item.physicalFormatLabel,
  );
}

GameRelease? _resolvePrimaryGameRelease(List<GameRelease> releases) {
  for (final release in releases) {
    if (release.isPrimary) {
      return release;
    }
  }
  return releases.isEmpty ? null : releases.first;
}

GameRelease? _gameReleaseById(List<GameRelease> releases, String? releaseId) {
  final normalized = releaseId?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  for (final release in releases) {
    if (release.id == normalized) {
      return release;
    }
  }
  return null;
}

GameRelease _gameReleaseFromCatalogEdition(
  CatalogEdition edition, {
  bool isPrimary = false,
}) {
  return GameRelease(
    id: edition.id,
    title: edition.title,
    platform: edition.physicalFormatLabel ?? edition.physicalFormat,
    releaseDate: edition.releaseDate,
    format: edition.format ?? edition.physicalFormatLabel,
    publisher: edition.publisher,
    catalogNumber: edition.upc,
    releaseStatus: null,
    language: edition.language,
    barcode: edition.upc,
    coverImageUrl: edition.variants.isNotEmpty
        ? edition.variants.first.coverImageUrl
        : null,
    isPrimary: isPrimary,
  );
}

const gamesLibraryMediaBuilder = GameLibraryMediaPresentationBuilder();

const gamesPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Items',
);

const gamesStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Series',
  topPublisher: 'Top Publishers / Studios',
);

const gamesLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Series',
  seriesPlural: 'Series',
  unknownSeries: 'Unknown series',
  publisher: 'Publisher / Studio',
  publisherPlural: 'Publishers / Studios',
  unknownPublisher: 'Unknown publisher / studio',
);

const gamesLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

String gamesLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    gamesLibraryGroupLabels,
    gamesLibraryBucketLabelOverrides,
  );
}

final gamesLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Version...',
    publisherHint: 'Publisher / Studio...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher / Studio',
    anyPublisher: 'Any publisher / studio',
  ),
  groupLabels: gamesLibraryGroupLabels,
  builder: gamesLibraryMediaBuilder,
  workspaceEntryBuilder: buildGamesLibraryWorkspaceEntryFromShelf,
  releaseEntryBuilder: buildGamesLibraryReleaseEntry,
  bucketLabelBuilder: gamesLibraryBucketLabelBuilder,
  previewLabels: gamesPreviewLabels,
  statsLabels: gamesStatsLabels,
  fieldDefinitions: gameLibraryFieldDefinitions,
  sortColumnDefinitions: gameLibrarySortColumnDefinitions,
  groupModeDefinitions: gameLibraryGroupModeDefinitions,
  groupModes: gameLibraryGroupModes,
);
