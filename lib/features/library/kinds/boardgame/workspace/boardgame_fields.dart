import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_group_bucket_mutation.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_ids.dart';
export 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_preference_codec.dart';

/// Single source of truth schema for BoardGame kind fields.
abstract final class BoardGameKindSchema {
  static final title = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final publisher = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.publisher,
    label: 'Publisher / Designer',
    getValue: (dto) => dto.publisher,
  );

  static final designer = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.designer,
    label: 'Designer',
    getValue: (dto) => dto.metadata?.designers.firstOrNull ?? dto.publisher,
  );

  static final releaseDate = dateField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.condition,
    label: 'Condition',
    getValue: (context) => context.source.ownedItem?.condition,
    scope: LibraryFieldScope.copy,
  );

  static final location =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    scope: LibraryFieldScope.copy,
  );

  static final pricePaid =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, int?>(
    id: BoardGameFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.ownedItem?.pricePaidCents,
    scope: LibraryFieldScope.copy,
  );

  static final barcode = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.barcode,
    label: 'UPC / Barcode',
    getValue: (dto) => dto.barcode,
    scope: LibraryFieldScope.release,
  );

  static final status =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    scope: LibraryFieldScope.copy,
  );

  static final cover =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    scope: LibraryFieldScope.media,
  );

  static final rating =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, int?>(
    id: BoardGameFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.source.ownedItem?.rating,
    scope: LibraryFieldScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, bool>(
    id: BoardGameFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    scope: LibraryFieldScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime>(
    id: BoardGameFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    scope: LibraryFieldScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime?>(
    id: BoardGameFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    scope: LibraryFieldScope.copy,
  );

  // Rich BoardGame Metadata Fields
  static final minPlayers = numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.minPlayers,
    label: 'Min Players',
    getValue: (dto) => dto.metadata?.minPlayers,
  );

  static final maxPlayers = numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.maxPlayers,
    label: 'Max Players',
    getValue: (dto) => dto.metadata?.maxPlayers,
  );

  static final bestPlayers = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.bestPlayers,
    label: 'Best Players',
    getValue: (dto) => dto.metadata?.bestPlayers,
  );

  static final recommendedPlayers =
      textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.recommendedPlayers,
    label: 'Recommended Players',
    getValue: (dto) => dto.metadata?.recommendedPlayers,
  );

  static final minPlaytimeMinutes =
      numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.minPlaytimeMinutes,
    label: 'Min Playtime (m)',
    getValue: (dto) => dto.metadata?.minPlaytimeMinutes,
  );

  static final maxPlaytimeMinutes =
      numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.maxPlaytimeMinutes,
    label: 'Max Playtime (m)',
    getValue: (dto) => dto.metadata?.maxPlaytimeMinutes,
  );

  static final complexityWeight =
      numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.complexityWeight,
    label: 'Complexity / Weight',
    getValue: (dto) => dto.metadata?.complexityWeight,
  );

  static final bggRating = numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.bggRating,
    label: 'BGG Rating',
    getValue: (dto) => dto.metadata?.bggRating,
  );

  static final bggRank = numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.bggRank,
    label: 'BGG Rank',
    getValue: (dto) => dto.metadata?.bggRank,
  );

  static final expansionFor = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.expansionFor,
    label: 'Expansion For',
    getValue: (dto) => dto.metadata?.expansionFor,
  );
}

final boardgameLibraryFacetDefinitions =
    <LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>>[
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    id: BoardGameFacetIds.publisher,
    label: 'Publisher',
    extractValues: (dto) => _boardGameFacetValues([
      ...?dto.metadata?.publishers,
      dto.metadata?.publisher,
      ...dto.boardgame.publishers,
      dto.boardgame.publisher,
      dto.publisher,
    ]),
  ),
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    id: BoardGameFacetIds.designer,
    label: 'Designer',
    extractValues: (dto) => _boardGameFacetValues([
      ...?dto.metadata?.designers,
      ...dto.boardgame.designers,
    ]),
  ),
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    id: BoardGameFacetIds.mechanic,
    label: 'Mechanic',
    extractValues: (dto) => _boardGameFacetValues([
      ...?dto.metadata?.mechanics,
      ...dto.boardgame.mechanics,
    ]),
  ),
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    id: BoardGameFacetIds.category,
    label: 'Category',
    extractValues: (dto) => _boardGameFacetValues([
      ...?dto.metadata?.categories,
      ...dto.boardgame.categories,
    ]),
  ),
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    id: BoardGameFacetIds.family,
    label: 'Family',
    extractValues: (dto) => _boardGameFacetValues([
      ...?dto.metadata?.families,
      ...dto.boardgame.families,
    ]),
  ),
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    id: BoardGameFacetIds.theme,
    label: 'Theme',
    extractValues: (dto) => _boardGameFacetValues([
      ...?dto.metadata?.themes,
      ...dto.boardgame.themes,
    ]),
  ),
];

Iterable<String> _boardGameFacetValues(Iterable<String?> values) sync* {
  final seen = <String>{};
  for (final value in values) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty || !seen.add(normalized)) {
      continue;
    }
    yield normalized;
  }
}

final boardgameLibraryFieldDefinitions = [
  BoardGameKindSchema.status,
  BoardGameKindSchema.cover,
  BoardGameKindSchema.title,
  BoardGameKindSchema.publisher,
  BoardGameKindSchema.designer,
  BoardGameKindSchema.releaseDate,
  BoardGameKindSchema.condition,
  BoardGameKindSchema.location,
  BoardGameKindSchema.pricePaid,
  BoardGameKindSchema.barcode,
  BoardGameKindSchema.rating,
  BoardGameKindSchema.wishlist,
  BoardGameKindSchema.updatedAt,
  BoardGameKindSchema.addedAt,
  BoardGameKindSchema.minPlayers,
  BoardGameKindSchema.maxPlayers,
  BoardGameKindSchema.bestPlayers,
  BoardGameKindSchema.recommendedPlayers,
  BoardGameKindSchema.minPlaytimeMinutes,
  BoardGameKindSchema.maxPlaytimeMinutes,
  BoardGameKindSchema.complexityWeight,
  BoardGameKindSchema.bggRating,
  BoardGameKindSchema.bggRank,
  BoardGameKindSchema.expansionFor,
];

final boardGamesLibraryGroupDefinitions = [
  groupFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameKindSchema.publisher,
    sidebarTitle: 'Publishers / Designers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: libraryStringListBucketValueMutator(
      'publishers',
      scalarMirrorKeys: ['publisher'],
    ),
  ),
  groupFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  groupFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameKindSchema.bestPlayers,
    sidebarTitle: 'Best Player Count',
    icon: Icons.group_outlined,
  ),
];

final boardGamesLibrarySortDefinitions = [
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, String>(
      BoardGameKindSchema.publisher),
  LibrarySortDefinition<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<BoardGameWorkspaceDto> ctx) {
        if (ctx.source.isOwned) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, String>(
      BoardGameKindSchema.title),
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, DateTime>(
      BoardGameKindSchema.releaseDate,
      defaultAscending: false),
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, num>(
      BoardGameKindSchema.bggRating,
      defaultAscending: false),
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, num>(
      BoardGameKindSchema.bggRank),
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, num>(
      BoardGameKindSchema.complexityWeight,
      defaultAscending: false),
];

final boardGamesLibraryDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  BoardGameFieldIds.status,
  BoardGameFieldIds.cover,
  BoardGameFieldIds.publisher,
  BoardGameFieldIds.title,
  BoardGameFieldIds.releaseDate,
  BoardGameFieldIds.barcode,
  BoardGameFieldIds.rating,
  BoardGameFieldIds.condition,
  BoardGameFieldIds.pricePaid,
  BoardGameFieldIds.location,
  BoardGameFieldIds.wishlist,
  BoardGameFieldIds.updatedAt,
};

final boardgameLibraryColumnDefinitions = [
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.status,
    label: 'Status',
    getValue: BoardGameKindSchema.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.cover,
    label: '',
    getValue: BoardGameKindSchema.cover.getValue,
    cellValue: (context) => context.dto.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            context.dto.coverImageUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
    sortable: false,
    groupable: false,
    defaultWidth: 42,
    minWidth: 44,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
      BoardGameKindSchema.publisher,
      defaultWidth: 160),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
      BoardGameKindSchema.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, DateTime?>(
    BoardGameKindSchema.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, bool>(
    id: BoardGameFieldIds.wishlist,
    label: 'Wishlist',
    getValue: BoardGameKindSchema.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime>(
    id: BoardGameFieldIds.updatedAt,
    label: 'Updated',
    getValue: BoardGameKindSchema.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime?>(
    id: BoardGameFieldIds.addedAt,
    label: 'Added',
    getValue: BoardGameKindSchema.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameKindSchema.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameKindSchema.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, int?>(
    BoardGameKindSchema.pricePaid,
    cellValue: (context) => Text(_formatCents(
        context.source.ownedItem?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameKindSchema.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, int?>(
    id: BoardGameFieldIds.rating,
    label: 'Rating',
    getValue: BoardGameKindSchema.rating.getValue,
    cellValue: (context) =>
        Text(context.source.ownedItem?.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, num?>(
    BoardGameKindSchema.minPlayers,
    group: 'Players',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, num?>(
    BoardGameKindSchema.maxPlayers,
    group: 'Players',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameKindSchema.bestPlayers,
    group: 'Players',
    defaultWidth: 100,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, num?>(
    BoardGameKindSchema.complexityWeight,
    group: 'Details',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, num?>(
    BoardGameKindSchema.bggRating,
    group: 'Details',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, num?>(
    BoardGameKindSchema.bggRank,
    group: 'Details',
    isNumeric: true,
    defaultWidth: 80,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameKindSchema.expansionFor,
    group: 'Details',
    defaultWidth: 150,
  ),
];

final boardgameLibraryKindSchema =
    LibraryKindSchema<BoardGameKind, BoardGameWorkspaceDto>(
  kindNamespace: 'boardgame',
  fields: boardgameLibraryFieldDefinitions,
  columns: boardgameLibraryColumnDefinitions,
  sorts: boardGamesLibrarySortDefinitions,
  groups: boardGamesLibraryGroupDefinitions,
  defaultVisibleColumns: boardGamesLibraryDefaultVisibleColumns,
  defaultSort: BoardGameSortIds.publisher,
  defaultGroup: BoardGameGroupIds.publisher,
  preferenceCodec: const BoardGamePreferenceCodec(),
);

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _formatCents(int? cents, String? currency) {
  if (cents == null) return '';
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null ? amount : '$currency $amount';
}
