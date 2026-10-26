import 'package:collectarr_app/features/library/kinds/game/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/groups.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_entry_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/config/game_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/dto.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';

const gamesMetadataLabels = LibraryMetadataLabels(
  values: {'creators': 'Creators', 'genres': 'Genres'},
);

const gamesLibraryMediaBuilder = GameLibraryMediaPresentationBuilder(
  metadataLabels: gamesMetadataLabels,
);

const gamesPreviewLabels = LibraryMediaPreviewLabels(
  values: {
    'series': 'Series',
    'item_count': 'Items',
    'item_number': 'Version',
    'publisher': 'Publisher',
    'variant': 'Platform / Edition',
    'barcode': 'UPC / Barcode',
  },
);

const gamesStatsLabels = LibraryMediaStatsLabels(
  values: {
    'top_series': 'Top Series',
    'top_publisher': 'Top Publishers',
  },
);

const gamesLibraryGroupLabels = LibraryPresentationLabels(
  values: {
    'series': 'Series',
    'series_plural': 'Series',
    'unknown_series': 'Unknown series',
    'publisher': 'Publisher',
    'publisher_plural': 'Publishers',
    'unknown_publisher': 'Unknown publisher',
  },
);

const gamesLibraryBucketLabelOverrides = LibraryPresentationLabels();

final gamesLibraryFilterDefinitions = <LibraryFilterDefinition<Object?>>[
  LibraryFilterDefinition<Object?>(
    metadata: GameWorkspaceFieldMetadata.series,
    id: 'series',
    label: 'Series',
    anyLabel: 'Any series',
    value: (item) => (item.dto is GameWorkspaceDto)
        ? (item.dto as GameWorkspaceDto).seriesTitle
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: LibraryEntryFieldMetadata.location,
    id: 'location',
    label: 'Location',
    anyLabel: 'Any location',
  ),
  LibraryFilterDefinition<Object?>(
    metadata: LibraryEntryFieldMetadata.tag,
    id: 'tag',
    label: 'Tag',
    anyLabel: 'Any tag',
    inputKind: LibraryFilterInputKind.autocomplete,
    value: (item) => GameLibraryEntryProjection.fromDispatch(
      item.source.libraryEntryDispatch,
    )?.personal.tags,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: GameWorkspaceFieldMetadata.publisher,
    id: 'publisher',
    label: 'Publisher',
    anyLabel: 'Any publisher',
    value: (item) => (item.dto is GameWorkspaceDto)
        ? (item.dto as GameWorkspaceDto).publisher
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: GameWorkspaceFieldMetadata.releaseYear,
    id: 'year',
    label: 'Year',
    anyLabel: 'Any year',
    value: (item) => (item.dto is GameWorkspaceDto)
        ? (item.dto as GameWorkspaceDto).releaseDate?.year.toString()
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: LibraryEntryFieldMetadata.condition,
    id: 'condition',
    label: 'Condition',
    anyLabel: 'Any condition',
    value: (item) => GameLibraryEntryProjection.fromDispatch(
      item.source.libraryEntryDispatch,
    )?.personal.condition,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: GameWorkspaceFieldMetadata.country,
    id: 'country',
    label: 'Country',
    anyLabel: 'Any country',
    value: (item) => (item.dto is GameWorkspaceDto)
        ? (item.dto as GameWorkspaceDto).country
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: GameWorkspaceFieldMetadata.language,
    id: 'language',
    label: 'Language',
    anyLabel: 'Any language',
    value: (item) => (item.dto is GameWorkspaceDto)
        ? (item.dto as GameWorkspaceDto).language
        : null,
  ),
];

String gamesLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    gamesLibraryGroupLabels,
    gamesLibraryBucketLabelOverrides,
  );
}

final gamesLibraryMediaPresentation = LibraryMediaPresentation(
  // Reference folder favorites.
  defaultFolderFavorites: [
    [GameGroupingField.platform.id],
    [GameGroupingField.completeness.id],
    [GameGroupingField.platform.id, GameGroupingField.completeness.id],
  ],
  // The reference's one built-in favorite, matching the default sort.
  sortFavorites: [
    LibrarySortFavorite(
        id: 'platform_title',
        label: 'Platform / Title',
        icon: AppIcons.sortAlpha,
        rules: [
          LibrarySortRule(column: GameSortIds.platform.value, ascending: true),
          LibrarySortRule(column: GameSortIds.title.value, ascending: true),
        ]),
  ],
  // Reference column favorites.
  duplicateColumns: [
    GameFieldIds.title.value,
    GameFieldIds.platform.value,
    GameFieldIds.releaseDate.value,
    'game.index',
    GameFieldIds.addedAt.value,
  ],
  columnFavorites: [
    LibraryTableColumnPreset(label: 'My List View columns', columns: {
      GameFieldIds.platformIcon.value,
      GameFieldIds.platform.value,
      GameFieldIds.title.value,
      GameFieldIds.releaseDate.value,
      GameFieldIds.publisher.value,
      GameFieldIds.developer.value,
      GameFieldIds.genre.value,
      GameFieldIds.addedAt.value,
    }),
    LibraryTableColumnPreset(label: 'My Find Duplicates columns', columns: {
      GameFieldIds.title.value,
      GameFieldIds.platform.value,
      GameFieldIds.releaseDate.value,
      'game.index',
      GameFieldIds.addedAt.value,
    }),
    LibraryTableColumnPreset(label: 'My Print / Export columns', columns: {
      GameFieldIds.platform.value,
      GameFieldIds.title.value,
      GameFieldIds.releaseDate.value,
      GameFieldIds.publisher.value,
      GameFieldIds.genre.value,
    }),
  ],
  searchFieldLabels: const LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title...',
    libraryHint: 'Search games...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
  ),
  filterLabels: const LibraryPresentationLabels(
    values: {
      'series': 'Series',
      'series_any': 'Any series',
      'publisher': 'Publisher',
      'publisher_any': 'Any publisher',
      'year': 'Year',
      'year_any': 'Any year',
    },
  ),
  groupLabels: gamesLibraryGroupLabels,
  builder: gamesLibraryMediaBuilder,
  bucketLabelBuilder: gamesLibraryBucketLabelBuilder,
  cardPresentationBuilder: buildGameCardPresentation,
  previewLabels: gamesPreviewLabels,
  statsLabels: gamesStatsLabels,
  filterDefinitions: gamesLibraryFilterDefinitions,
);
