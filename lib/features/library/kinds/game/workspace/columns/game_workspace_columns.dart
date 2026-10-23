import 'package:collectarr_app/features/library/kinds/game/config/game_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_personal_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/presentation/game_workspace_formatting.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:flutter/material.dart';

/// Columns of a collection's own copies, beside the catalog columns.
final gamePersonalWorkspaceColumns = [
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.status,
    metadata: GameWorkspaceFieldMetadata.status,
    getValue: GamePersonalWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.personal.isWishlisted
        ? 'Wishlist'
        : ((context.item.entrySummary != null) ? 'Entry' : '')),
    allowSortInteraction: false,
    allowGroupInteraction: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, bool>(
    id: GameFieldIds.wishlist,
    metadata: GameWorkspaceFieldMetadata.wishlist,
    getValue: GamePersonalWorkspaceFields.wishlist.getValue,
    cellValue: (context) =>
        Text(context.personal.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, DateTime>(
    id: GameFieldIds.updatedAt,
    metadata: GameWorkspaceFieldMetadata.updatedAt,
    getValue: GamePersonalWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(formatGameDate(context.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GamePersonalWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GamePersonalWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<GameKind, GameWorkspaceDto, int?>(
    GamePersonalWorkspaceFields.pricePaid,
    cellValue: (context) => Text(formatGameCents(
        context.item.entrySummary?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, int?>(
    id: GameFieldIds.rating,
    metadata: GameWorkspaceFieldMetadata.rating,
    getValue: GamePersonalWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
  for (final field in [
    GamePersonalWorkspaceFields.loosePrice,
    GamePersonalWorkspaceFields.cibPrice,
    GamePersonalWorkspaceFields.newPrice,
    GamePersonalWorkspaceFields.gradedPrice,
    GamePersonalWorkspaceFields.boxOnlyPrice,
    GamePersonalWorkspaceFields.manualOnlyPrice,
  ])
    columnFromField<GameKind, GameWorkspaceDto, num?>(
      field,
      cellValue: (context) => Text(formatGameCents(
          field.getValue(context)?.toInt(), context.dto.currency)),
      group: 'Valuation',
      isNumeric: true,
      defaultWidth: 100,
    ),
];
