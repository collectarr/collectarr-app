import 'package:collectarr_app/core/models/catalog_item_types.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_domain.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace_entry_builder.dart'
    show
        BoardGamePersonalOverlay,
        buildBoardGameEditionWorkspaceEntry,
        buildBoardGameWorkspaceEntry;
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_field_definitions.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const boardGamesLibraryMediaBuilder = BoardGameLibraryMediaPresentationBuilder();

const boardGamesPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Items',
);

const boardGamesStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Series',
  topPublisher: 'Top Publishers / Designers',
);

const boardGamesLibraryGroupModes = [
  LibraryGroupMode.publisher,
  LibraryGroupMode.series,
  LibraryGroupMode.year,
  LibraryGroupMode.location,
  LibraryGroupMode.title,
  LibraryGroupMode.ownership,
];

const boardGamesLibraryGroupModeDefinitions = [
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.publisher,
    label: 'Publisher / Designer',
    sidebarTitle: 'Publishers / Designers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.series,
    label: 'Series',
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.year,
    label: 'Year',
    sidebarTitle: 'Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.location,
    label: 'Location',
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.title,
    label: 'Title',
    sidebarTitle: 'Titles',
    icon: Icons.sort_by_alpha,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.ownership,
    label: 'Ownership',
    sidebarTitle: 'Ownership',
    icon: Icons.inventory_2_outlined,
  ),
];

const boardGamesLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Series',
  seriesPlural: 'Series',
  unknownSeries: 'Unknown series',
  publisher: 'Publisher / Designer',
  publisherPlural: 'Publishers / Designers',
  unknownPublisher: 'Unknown publisher / designer',
);

const boardGamesLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

String boardGamesLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return _simpleLibraryBucketLabel(
    context,
    boardGamesLibraryGroupLabels,
    boardGamesLibraryBucketLabelOverrides,
  );
}

String _simpleLibraryBucketLabel(
  LibraryBucketingContext context,
  LibraryMediaGroupLabels labels,
  LibraryBucketLabelOverrides overrides,
) {
  final entry = context.entry;
  final publisher = entry.publisher?.trim();
  return switch (context.groupMode) {
    LibraryGroupMode.series => _seriesBucket(entry, labels.unknownSeries),
    LibraryGroupMode.year =>
      entry.releaseYear?.toString() ??
          (entry.releaseDate?.year.toString() ?? 'Unknown year'),
    LibraryGroupMode.publisher =>
      publisher == null || publisher.isEmpty ? labels.unknownPublisher : publisher,
    LibraryGroupMode.location => _locationBucket(entry.locationPath),
    LibraryGroupMode.title => _titleBucket(entry.resolvedTitle),
    LibraryGroupMode.ownership => entry.isOwned
        ? overrides.owned
        : entry.isWishlisted
        ? overrides.wishlist
        : overrides.catalogOnly,
    _ => context.groupMode.name,
  };
}

String _seriesBucket(LibraryWorkspaceEntry entry, String unknownLabel) {
  final seriesTitle = entry.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  return unknownLabel;
}

String _locationBucket(String? location) {
  final normalized = location?.trim();
  if (normalized == null || normalized.isEmpty) {
    return 'No location';
  }
  return normalized;
}

String _titleBucket(String title) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? 'Unknown' : trimmed.substring(0, 1).toUpperCase();
}

const boardGamesLibrarySortColumnDefinitions = [
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.series,
    label: 'Series',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.publisher,
    label: 'Publisher / Designer',
  ),
  LibrarySortColumnDefinition(column: LibrarySortColumn.status, label: 'Status'),
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
  LibrarySortColumnDefinition(column: LibrarySortColumn.country, label: 'Country'),
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
  LibrarySortColumnDefinition(column: LibrarySortColumn.imprint, label: 'Imprint'),
];

const boardGamesLibrarySortColumns = [
  LibrarySortColumn.status,
  LibrarySortColumn.title,
  LibrarySortColumn.series,
  LibrarySortColumn.issue,
  LibrarySortColumn.storyArc,
  LibrarySortColumn.variant,
  LibrarySortColumn.format,
  LibrarySortColumn.publisher,
  LibrarySortColumn.releaseDate,
  LibrarySortColumn.barcode,
  LibrarySortColumn.grade,
  LibrarySortColumn.condition,
  LibrarySortColumn.price,
  LibrarySortColumn.location,
  LibrarySortColumn.collectionStatus,
  LibrarySortColumn.wishlist,
  LibrarySortColumn.keyComic,
  LibrarySortColumn.added,
  LibrarySortColumn.updated,
  LibrarySortColumn.country,
  LibrarySortColumn.language,
  LibrarySortColumn.pageCount,
  LibrarySortColumn.ageRating,
  LibrarySortColumn.imprint,
];

final boardGamesLibraryFieldDefinitions =
    libraryWorkspaceFieldDefinitionsForKind('boardgame');

final boardGamesLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Edition...',
    publisherHint: 'Publisher / Designer...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher / Designer',
    anyPublisher: 'Any publisher / designer',
  ),
  groupLabels: boardGamesLibraryGroupLabels,
  builder: boardGamesLibraryMediaBuilder,
  workspaceEntryBuilder: buildBoardGamesLibraryWorkspaceEntryFromShelf,
  releaseEntryBuilder: buildBoardGamesLibraryReleaseEntry,
  bucketLabelBuilder: boardGamesLibraryBucketLabelBuilder,
  previewLabels: boardGamesPreviewLabels,
  statsLabels: boardGamesStatsLabels,
  fieldDefinitions: boardGamesLibraryFieldDefinitions,
  sortColumnDefinitions: boardGamesLibrarySortColumnDefinitions,
  groupModeDefinitions: boardGamesLibraryGroupModeDefinitions,
  groupModes: boardGamesLibraryGroupModes,
);

LibraryWorkspaceEntry buildBoardGamesLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final catalogItem = source.catalogItem!;
  return buildBoardGameWorkspaceEntry(
    _boardGameWorkFromMetadataItem(catalogItem),
    BoardGamePersonalOverlay.fromShelfEntry(source),
  );
}

LibraryWorkspaceEntry buildBoardGamesLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final titleEntry = request.titleEntry;
  if (titleEntry is! BoardGameWorkspaceEntry || titleEntry.boardGameWork == null) {
    throw StateError('BoardGame release entry requires a typed boardGameWork');
  }
  final work = titleEntry.boardGameWork!;
  final edition = _boardGameEditionById(
        work.editions,
        request.referenceEditionId,
      ) ??
      _primaryBoardGameEdition(work) ??
      BoardGameEdition(
        id: request.referenceEditionId ?? request.edition.id,
        title: request.edition.title,
        format: request.edition.format,
        publisher: request.edition.publisher,
        catalogNumber: request.edition.upc,
        barcode: request.edition.upc,
        releaseDate: request.edition.releaseDate,
        language: request.edition.language,
        country: request.edition.region,
        coverImageUrl: request.edition.variants.isNotEmpty
            ? request.edition.variants.first.coverImageUrl
            : null,
      );
  return buildBoardGameEditionWorkspaceEntry(
    titleEntry: titleEntry,
    edition: edition,
    overlay: BoardGamePersonalOverlay(updatedAt: request.updatedAt),
  );
}

BoardGameWork _boardGameWorkFromMetadataItem(LibraryMetadataItem item) {
  return BoardGameWork(
    id: item.id,
    title: item.title,
    identifiers: const <String>[],
    contributors: item.creators == null
        ? const <String>[]
        : List<String>.unmodifiable(
            item.creators!
                .map((creator) => creator['name']?.toString() ?? '')
                .where((name) => name.isNotEmpty),
          ),
    mechanics: const <String>[],
    categories: item.genres == null
        ? const <String>[]
        : List<String>.unmodifiable(item.genres!),
    families: const <String>[],
    expansions: const <String>[],
    rankings: const <String>[],
    playStats: item.boardGameStats == null
        ? null
        : BoardGamePlayStats.fromDetails(item.boardGameStats!),
    editions: [
      for (final edition in item.editions)
        _boardGameEditionFromCatalogEdition(edition),
    ],
  );
}

BoardGameEdition _boardGameEditionFromCatalogEdition(CatalogEdition edition) {
  return BoardGameEdition(
    id: edition.id,
    title: edition.title,
    editionTitle: edition.title,
    format: edition.format,
    publisher: edition.publisher,
    catalogNumber: edition.upc,
    barcode: edition.upc,
    releaseDate: edition.releaseDate,
    language: edition.language,
    country: edition.region,
    coverImageUrl: edition.variants.isNotEmpty
        ? edition.variants.first.coverImageUrl
        : null,
  );
}

BoardGameEdition? _boardGameEditionById(
  List<BoardGameEdition> editions,
  String? editionId,
) {
  final normalized = editionId?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  for (final edition in editions) {
    if (edition.id == normalized) {
      return edition;
    }
  }
  return null;
}

BoardGameEdition? _primaryBoardGameEdition(BoardGameWork work) {
  return work.editions.isEmpty ? null : work.editions.first;
}