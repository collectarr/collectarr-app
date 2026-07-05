import 'package:collectarr_app/core/models/catalog_item_types.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/game/game_domain.dart';
import 'package:collectarr_app/features/library/kinds/game/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/shared/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';

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
  final release = _gameReleaseById(entry.gameReleases, request.referenceEditionId) ??
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

const gamesLibraryGroupModes = [
  // Main
  LibraryGroupMode.audienceRating,
  LibraryGroupMode.developer,
  LibraryGroupMode.genre,
  LibraryGroupMode.platform,
  LibraryGroupMode.publisher,
  LibraryGroupMode.releaseDate,
  LibraryGroupMode.releaseMonth,
  LibraryGroupMode.releaseYear,
  LibraryGroupMode.series,
  LibraryGroupMode.title,
  // Value
  LibraryGroupMode.completeness,
  LibraryGroupMode.condition,
  LibraryGroupMode.purchaseDate,
  LibraryGroupMode.purchaseMonth,
  LibraryGroupMode.purchaseStore,
  LibraryGroupMode.purchaseYear,
  LibraryGroupMode.valueLocked,
  // Toy
  LibraryGroupMode.toySubtype,
  LibraryGroupMode.toyType,
  // Edition
  LibraryGroupMode.format,
  LibraryGroupMode.regions,
  // Personal
  LibraryGroupMode.addedDate,
  LibraryGroupMode.addedMonth,
  LibraryGroupMode.addedYear,
  LibraryGroupMode.collectionStatus,
  LibraryGroupMode.completed,
  LibraryGroupMode.completedDate,
  LibraryGroupMode.completedMonth,
  LibraryGroupMode.completedYear,
  LibraryGroupMode.imageType,
  LibraryGroupMode.location,
  LibraryGroupMode.modifiedDate,
  LibraryGroupMode.modifiedMonth,
  LibraryGroupMode.myRating,
  LibraryGroupMode.owner,
  LibraryGroupMode.storageDevice,
  LibraryGroupMode.tags,
];

const gamesLibraryGroupModeDefinitions = [
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.title,
    label: 'Title',
    sidebarTitle: 'Titles',
    icon: Icons.sort_by_alpha,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.audienceRating,
    label: 'Audience Rating',
    sidebarTitle: 'Audience Ratings',
    icon: Icons.groups_2_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.developer,
    label: 'Developer',
    sidebarTitle: 'Developers',
    icon: Icons.code_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.genre,
    label: 'Genre',
    sidebarTitle: 'Genres',
    icon: Icons.theater_comedy_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.platform,
    label: 'Platform',
    sidebarTitle: 'Platforms',
    icon: Icons.sports_esports_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.publisher,
    label: 'Publisher / Studio',
    sidebarTitle: 'Publishers / Studios',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.releaseDate,
    label: 'Release Date',
    sidebarTitle: 'Release Dates',
    icon: Icons.event_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.releaseMonth,
    label: 'Release Month',
    sidebarTitle: 'Release Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.releaseYear,
    label: 'Release Year',
    sidebarTitle: 'Release Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.series,
    label: 'Series',
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.completeness,
    label: 'Completeness',
    sidebarTitle: 'Completeness',
    icon: Icons.checklist_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.condition,
    label: 'Condition',
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.purchaseDate,
    label: 'Purchase Date',
    sidebarTitle: 'Purchase Dates',
    icon: Icons.shopping_bag_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.purchaseMonth,
    label: 'Purchase Month',
    sidebarTitle: 'Purchase Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.purchaseStore,
    label: 'Purchase Store',
    sidebarTitle: 'Purchase Stores',
    icon: Icons.store_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.purchaseYear,
    label: 'Purchase Year',
    sidebarTitle: 'Purchase Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.valueLocked,
    label: 'Value Locked',
    sidebarTitle: 'Value Locked',
    icon: Icons.lock_outline,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.toySubtype,
    label: 'Subtype',
    sidebarTitle: 'Subtypes',
    icon: Icons.category_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.toyType,
    label: 'Type',
    sidebarTitle: 'Types',
    icon: Icons.toys_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.format,
    label: 'Format',
    sidebarTitle: 'Formats',
    icon: Icons.album_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.regions,
    label: 'Region',
    sidebarTitle: 'Regions',
    icon: Icons.public_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.addedDate,
    label: 'Added Date',
    sidebarTitle: 'Added Dates',
    icon: Icons.add_circle_outline,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.addedMonth,
    label: 'Added Month',
    sidebarTitle: 'Added Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.addedYear,
    label: 'Added Year',
    sidebarTitle: 'Added Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.collectionStatus,
    label: 'Collection Status',
    sidebarTitle: 'Collection Status',
    icon: Icons.bookmark_added_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.completed,
    label: 'Completed',
    sidebarTitle: 'Completed',
    icon: Icons.task_alt_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.completedDate,
    label: 'Completed Date',
    sidebarTitle: 'Completed Dates',
    icon: Icons.event_available_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.completedMonth,
    label: 'Completed Month',
    sidebarTitle: 'Completed Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.completedYear,
    label: 'Completed Year',
    sidebarTitle: 'Completed Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.imageType,
    label: 'Image Type',
    sidebarTitle: 'Image Types',
    icon: Icons.image_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.location,
    label: 'Location',
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.modifiedDate,
    label: 'Modified Date',
    sidebarTitle: 'Modified Dates',
    icon: Icons.edit_calendar_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.modifiedMonth,
    label: 'Modified Month',
    sidebarTitle: 'Modified Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.myRating,
    label: 'My Rating',
    sidebarTitle: 'Ratings',
    icon: Icons.star_outline,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.owner,
    label: 'Owner',
    sidebarTitle: 'Owners',
    icon: Icons.person_outline,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.storageDevice,
    label: 'Storage Device',
    sidebarTitle: 'Storage Devices',
    icon: Icons.sd_storage_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.tags,
    label: 'Tags',
    sidebarTitle: 'Tags',
    icon: Icons.local_offer_outlined,
    supportsBucketManagement: true,
  ),
];

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

const gamesLibrarySortColumnDefinitions = [
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.series,
    label: 'Series',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.publisher,
    label: 'Publisher / Studio',
  ),
  LibrarySortColumnDefinition(
      column: LibrarySortColumn.status, label: 'Status'),
  LibrarySortColumnDefinition(column: LibrarySortColumn.title, label: 'Title'),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.issue,
    label: 'Issue / number',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.storyArc,
    label: 'Story arc',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.variant,
    label: 'Variant',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.format,
    label: 'Format',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.releaseDate,
    label: 'Release date',
    defaultAscending: false,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.barcode,
    label: 'Barcode',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.grade,
    label: 'Grade',
    group: LibrarySortFieldGroup.value,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.condition,
    label: 'Condition',
    group: LibrarySortFieldGroup.value,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.price,
    label: 'Purchase price',
    group: LibrarySortFieldGroup.value,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.location,
    label: 'Location',
    group: LibrarySortFieldGroup.personal,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.collectionStatus,
    label: 'Collection status',
    group: LibrarySortFieldGroup.personal,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.wishlist,
    label: 'Wishlist',
    group: LibrarySortFieldGroup.personal,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.added,
    label: 'Added date',
    group: LibrarySortFieldGroup.personal,
    defaultAscending: false,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.updated,
    label: 'Updated',
    group: LibrarySortFieldGroup.personal,
    defaultAscending: false,
  ),
  LibrarySortColumnDefinition(
      column: LibrarySortColumn.country, label: 'Country'),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.language,
    label: 'Language',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.pageCount,
    label: 'Page count',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.ageRating,
    label: 'Age rating',
  ),
  LibrarySortColumnDefinition(
      column: LibrarySortColumn.imprint, label: 'Imprint'),
];

const gamesLibraryMediaPresentation = LibraryMediaPresentation(
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
  sortColumnDefinitions: gamesLibrarySortColumnDefinitions,
  groupModeDefinitions: gamesLibraryGroupModeDefinitions,
  groupModes: gamesLibraryGroupModes,
);
