import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_value_summary.dart';
import 'package:collectarr_app/features/library/kinds/game/config/game_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_personal_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/presentation/game_workspace_formatting.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart'
    show libraryCollectionStatusFromValue;
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart'
    show LibraryCollectionStatusScopeUi;
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:flutter/material.dart';

/// Columns of a collection's own copies, beside the catalog columns. Labels
/// and groups follow the reference Games column chooser.
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
  // Value
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GamePersonalWorkspaceFields.completeness,
    cellValue: (context) => Text(gameCompletenessOptions
            .where((option) =>
                option.$1 ==
                GamePersonalWorkspaceFields.completeness.getValue(context))
            .firstOrNull
            ?.$2 ??
        ''),
    sortId: const LibrarySortId('game.completeness_sort'),
    group: 'Value',
    defaultWidth: 120,
  ),
  _yesNoColumn(GamePersonalWorkspaceFields.hasBox, 'Box', 'game.box'),
  _yesNoColumn(GamePersonalWorkspaceFields.hasManual, 'Manual', 'game.manual'),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GamePersonalWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GamePersonalWorkspaceFields.priceChartingId,
    sortId: const LibrarySortId('game.pricecharting_id_sort'),
    group: 'Value',
    defaultWidth: 120,
  ),
  columnFromField<GameKind, GameWorkspaceDto, PartialDate?>(
    GamePersonalWorkspaceFields.purchaseDate,
    cellValue: (context) => Text(AppFormats.current.formatPartialDate(
        GamePersonalWorkspaceFields.purchaseDate.getValue(context))),
    sortId: const LibrarySortId('game.purchase_date_sort'),
    group: 'Value',
    defaultWidth: 118,
  ),
  columnFromField<GameKind, GameWorkspaceDto, int?>(
    GamePersonalWorkspaceFields.pricePaid,
    cellValue: (context) => Text(formatGameCents(
        context.item.entrySummary?.pricePaidCents, context.dto.currency)),
    sortId: const LibrarySortId('game.purchase_price'),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GamePersonalWorkspaceFields.purchaseStore,
    sortId: const LibrarySortId('game.purchase_store_sort'),
    group: 'Value',
    defaultWidth: 130,
  ),
  _yearColumn(GamePersonalWorkspaceFields.purchaseYear, 'Value'),
  columnFromField<GameKind, GameWorkspaceDto, int?>(
    GamePersonalWorkspaceFields.value,
    cellValue: (context) => Text(formatGameCents(
        GamePersonalWorkspaceFields.value.getValue(context),
        context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 100,
  ),
  _yesNoColumn(GamePersonalWorkspaceFields.valueLocked, 'Value Locked', null),
  for (final (field, label) in [
    (GamePersonalWorkspaceFields.loosePrice, 'Value Loose'),
    (GamePersonalWorkspaceFields.cibPrice, 'Value CiB'),
    (GamePersonalWorkspaceFields.newPrice, 'Value New'),
    (GamePersonalWorkspaceFields.gradedPrice, 'Value Graded'),
    (GamePersonalWorkspaceFields.boxOnlyPrice, 'Value Box Only'),
    (GamePersonalWorkspaceFields.manualOnlyPrice, 'Value Manual Only'),
  ])
    columnFromField<GameKind, GameWorkspaceDto, num?>(
      field,
      cellValue: (context) => Text(formatGameCents(
          field.getValue(context)?.toInt(), context.dto.currency)),
      displayName: label,
      group: 'Value',
      isNumeric: true,
      defaultWidth: 100,
    ),
  // Edition
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GamePersonalWorkspaceFields.coreRegion,
    displayName: 'Core Region',
    group: 'Edition',
    defaultWidth: 110,
  ),
  // Personal
  columnFromField<GameKind, GameWorkspaceDto, DateTime?>(
    GamePersonalWorkspaceFields.addedDateTime,
    cellValue: (context) => Text(
        _dateTime(GamePersonalWorkspaceFields.addedDateTime.getValue(context))),
    sortId: const LibrarySortId('game.added_date_sort'),
    group: 'Personal',
    defaultWidth: 150,
  ),
  _yearColumn(GamePersonalWorkspaceFields.addedYear, 'Personal'),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GamePersonalWorkspaceFields.completionStatus,
    cellValue: (context) {
      final value =
          GamePersonalWorkspaceFields.completionStatus.getValue(context);
      return Text(
          value == null ? '' : libraryCollectionStatusFromValue(value).label);
    },
    group: 'Personal',
    defaultWidth: 130,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GamePersonalWorkspaceFields.completed,
    group: 'Personal',
    defaultWidth: 96,
  ),
  columnFromField<GameKind, GameWorkspaceDto, PartialDate?>(
    GamePersonalWorkspaceFields.completedDate,
    cellValue: (context) => Text(AppFormats.current.formatPartialDate(
        GamePersonalWorkspaceFields.completedDate.getValue(context))),
    sortId: const LibrarySortId('game.completed_date_sort'),
    group: 'Personal',
    defaultWidth: 118,
  ),
  _yearColumn(GamePersonalWorkspaceFields.completedYear, 'Personal'),
  columnFromField<GameKind, GameWorkspaceDto, int?>(
    GamePersonalWorkspaceFields.index,
    group: 'Personal',
    isNumeric: true,
    defaultWidth: 72,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GamePersonalWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, DateTime>(
    id: GameFieldIds.updatedAt,
    metadata: GameWorkspaceFieldMetadata.updatedAt,
    getValue: GamePersonalWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(formatGameDate(context.updatedAt)),
    displayName: 'Modified Date',
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<GameKind, GameWorkspaceDto, DateTime>(
    GamePersonalWorkspaceFields.modifiedDateTime,
    cellValue: (context) => Text(_dateTime(
        GamePersonalWorkspaceFields.modifiedDateTime.getValue(context))),
    sortId: const LibrarySortId('game.modified_date_sort'),
    group: 'Personal',
    defaultWidth: 150,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, int?>(
    id: GameFieldIds.rating,
    metadata: GameWorkspaceFieldMetadata.rating,
    getValue: GamePersonalWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    displayName: 'My Rating',
    sortId: const LibrarySortId('game.my_rating'),
    group: 'Personal',
    defaultWidth: 80,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GamePersonalWorkspaceFields.notes,
    group: 'Personal',
    defaultWidth: 200,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GamePersonalWorkspaceFields.owner,
    sortId: const LibrarySortId('game.owner_sort'),
    group: 'Personal',
    defaultWidth: 120,
  ),
  columnFromField<GameKind, GameWorkspaceDto, int?>(
    GamePersonalWorkspaceFields.quantity,
    group: 'Personal',
    isNumeric: true,
    defaultWidth: 72,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GamePersonalWorkspaceFields.storage,
    group: 'Personal',
    defaultWidth: 120,
  ),
  columnFromField<GameKind, GameWorkspaceDto, Iterable<String>>(
    GamePersonalWorkspaceFields.tags,
    cellValue: (context) =>
        Text(GamePersonalWorkspaceFields.tags.getValue(context).join(', ')),
    group: 'Personal',
    defaultWidth: 150,
  ),
];

/// Columns of the copy's open loan, in the reference Loan group.
final gameLoanWorkspaceColumns = [
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GamePersonalWorkspaceFields.loanedTo,
    group: 'Loan',
    defaultWidth: 130,
  ),
  for (final field in [
    GamePersonalWorkspaceFields.loanDate,
    GamePersonalWorkspaceFields.dueDate,
  ])
    columnFromField<GameKind, GameWorkspaceDto, DateTime?>(
      field,
      cellValue: (context) => Text(formatGameDate(field.getValue(context))),
      group: 'Loan',
      defaultWidth: 112,
    ),
];

LibraryColumnDefinition<GameKind, GameWorkspaceDto, bool?> _yesNoColumn(
  LibraryFieldDefinition<GameKind, GameWorkspaceDto, bool?> field,
  String label,
  String? sortId,
) =>
    columnFromField<GameKind, GameWorkspaceDto, bool?>(
      field,
      cellValue: (context) => Text(switch (field.getValue(context)) {
        true => 'Yes',
        false => 'No',
        null => '',
      }),
      displayName: label,
      sortId: sortId == null ? null : LibrarySortId(sortId),
      allowSortInteraction: sortId != null,
      group: 'Value',
      defaultWidth: 84,
    );

LibraryColumnDefinition<GameKind, GameWorkspaceDto, int?> _yearColumn(
  LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?> field,
  String group,
) =>
    columnFromField<GameKind, GameWorkspaceDto, int?>(
      field,
      cellValue: (context) => Text('${field.getValue(context) ?? ''}'),
      group: group,
      isNumeric: true,
      defaultWidth: 96,
    );

String _dateTime(DateTime? value) =>
    value == null ? '' : AppFormats.current.formatDateTime(value);
