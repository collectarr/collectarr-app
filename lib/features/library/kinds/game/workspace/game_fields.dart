import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
export 'package:collectarr_app/features/library/kinds/game/workspace/game_preference_codec.dart';

/// Single source of truth schema for Game kind fields.
abstract final class GameKindSchema {
  static final title = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final publisher = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  );

  static final platform = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.platform,
    label: 'Platform',
    getValue: (dto) => dto.format,
  );

  static final developer = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.developer,
    label: 'Developer',
    getValue: (dto) => dto.creator,
  );

  static final releaseDate = dateField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition = LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.condition,
    label: 'Condition',
    getValue: (context) => context.source.ownedItem?.condition,
  );

  static final location = LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
  );

  static final pricePaid = LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: GameFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.ownedItem?.pricePaidCents,
  );

  static final barcode = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.barcode,
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
  );

  static final status = LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
  );

  static final cover = LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
  );

  static final rating = LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: GameFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.source.ownedItem?.rating,
  );

  static final wishlist = LibraryFieldDefinition<GameKind, GameWorkspaceDto, bool>(
    id: GameFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
  );

  static final updatedAt = LibraryFieldDefinition<GameKind, GameWorkspaceDto, DateTime>(
    id: GameFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
  );

  static final addedAt = LibraryFieldDefinition<GameKind, GameWorkspaceDto, DateTime?>(
    id: GameFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
  );

  static final completionStatus = LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.completionStatus,
    label: 'Completion',
    getValue: (context) => context.source.ownedItem?.collectionStatus,
  );
}

final gameLibraryFieldDefinitions = [
  GameKindSchema.title,
  GameKindSchema.platform,
  GameKindSchema.publisher,
  GameKindSchema.developer,
  GameKindSchema.releaseDate,
  GameKindSchema.condition,
  GameKindSchema.location,
  GameKindSchema.pricePaid,
  GameKindSchema.barcode,
];

final gameLibraryGroupDefinitions = [
  groupFromField<GameKind, GameWorkspaceDto, String?>(
    GameKindSchema.platform,
    sidebarTitle: 'Platforms',
    icon: Icons.videogame_asset_outlined,
  ),
  groupFromField<GameKind, GameWorkspaceDto, String?>(
    GameKindSchema.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField<GameKind, GameWorkspaceDto, String?>(
    GameKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final gameLibrarySortDefinitions = [
  sortFromField<GameKind, GameWorkspaceDto, String>(GameKindSchema.platform),
  sortFromField<GameKind, GameWorkspaceDto, String>(GameKindSchema.publisher),
  LibrarySortDefinition<GameKind, GameWorkspaceDto>(
    id: GameSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<GameWorkspaceDto> ctx) {
        if (ctx.source.isOwned) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
  sortFromField<GameKind, GameWorkspaceDto, String>(GameKindSchema.title),
  sortFromField<GameKind, GameWorkspaceDto, DateTime>(GameKindSchema.releaseDate, defaultAscending: false),
];

final gameLibraryDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  GameFieldIds.status,
  GameFieldIds.cover,
  GameFieldIds.platform,
  GameFieldIds.title,
  GameFieldIds.publisher,
  GameFieldIds.releaseDate,
  GameFieldIds.barcode,
  GameFieldIds.rating,
  GameFieldIds.condition,
  GameFieldIds.pricePaid,
  GameFieldIds.location,
  GameFieldIds.wishlist,
  GameFieldIds.updatedAt,
};

final gameLibraryColumnDefinitions = [
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.status,
    label: 'Status',
    getValue: GameKindSchema.status.getValue,
    cellValue: (context) =>
        Text(context.source.isWishlisted ? 'Wishlist' : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.cover,
    label: '',
    getValue: GameKindSchema.cover.getValue,
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
  columnFromField<GameKind, GameWorkspaceDto, String?>(GameKindSchema.platform, defaultWidth: 120),
  columnFromField<GameKind, GameWorkspaceDto, String?>(GameKindSchema.title, defaultWidth: 260, maxWidth: 520),
  columnFromField<GameKind, GameWorkspaceDto, String?>(GameKindSchema.publisher, defaultWidth: 140),
  columnFromField<GameKind, GameWorkspaceDto, DateTime?>(
    GameKindSchema.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, bool>(
    id: GameFieldIds.wishlist,
    label: 'Wishlist',
    getValue: GameKindSchema.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, DateTime>(
    id: GameFieldIds.updatedAt,
    label: 'Updated',
    getValue: GameKindSchema.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, DateTime?>(
    id: GameFieldIds.addedAt,
    label: 'Added',
    getValue: GameKindSchema.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameKindSchema.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameKindSchema.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<GameKind, GameWorkspaceDto, int?>(
    GameKindSchema.pricePaid,
    cellValue: (context) => Text(_formatCents(context.source.ownedItem?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameKindSchema.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, int?>(
    id: GameFieldIds.rating,
    label: 'Rating',
    getValue: GameKindSchema.rating.getValue,
    cellValue: (context) => Text(context.source.ownedItem?.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final gameLibraryKindSchema = LibraryKindSchema<GameKind, GameWorkspaceDto>(
  kindNamespace: 'game',
  fields: gameLibraryFieldDefinitions,
  columns: gameLibraryColumnDefinitions,
  sorts: gameLibrarySortDefinitions,
  groups: gameLibraryGroupDefinitions,
  defaultVisibleColumns: gameLibraryDefaultVisibleColumns,
  defaultSort: GameSortIds.platform,
  defaultGroup: GameGroupIds.platform,
  preferenceCodec: const GamePreferenceCodec(),
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
