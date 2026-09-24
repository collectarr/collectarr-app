import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class BoardGameReleaseWorkspaceFields {
  static final publisher = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.publisher,
    label: 'Publisher / Designer',
    getValue: (dto) => dto.publisher,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseDate = dateField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
    entityScope: LibraryEntityScope.release,
  );

  static final barcode = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.barcode,
    label: 'UPC / Barcode',
    getValue: (dto) => dto.barcode,
    entityScope: LibraryEntityScope.release,
  );
}

final boardgameReleaseWorkspaceFieldDefinitions = [
  BoardGameReleaseWorkspaceFields.publisher,
  BoardGameReleaseWorkspaceFields.releaseDate,
  BoardGameReleaseWorkspaceFields.barcode,
];

final boardgameReleaseWorkspaceGroupDefinitions = [
  groupFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameReleaseWorkspaceFields.publisher,
    sidebarTitle: 'Publishers / Designers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringListBucketValueMutator(
      'publishers',
      scalarMirrorKeys: ['publisher'],
    ),
  ),
];

final boardgameReleaseWorkspaceSortDefinitions = [
  LibrarySortDefinition<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameSortIds.releaseTitle,
    label: 'Release title',
    entityScope: LibraryEntityScope.release,
    compare: (left, right) => left.dto.title.compareTo(right.dto.title),
  ),
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, String>(
      BoardGameReleaseWorkspaceFields.publisher),
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, DateTime>(
      BoardGameReleaseWorkspaceFields.releaseDate,
      defaultAscending: false),
];

final boardgameReleaseWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  BoardGameFieldIds.publisher,
  BoardGameFieldIds.releaseDate,
  BoardGameFieldIds.barcode,
};

final boardgameReleaseWorkspaceColumnDefinitions = [
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
      BoardGameReleaseWorkspaceFields.publisher,
      defaultWidth: 160),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, DateTime?>(
    BoardGameReleaseWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameReleaseWorkspaceFields.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
];

final boardgameReleaseWorkspaceSchema =
    LibraryEntityWorkspaceSchema<BoardGameKind, BoardGameWorkspaceDto>(
  kindNamespace: 'boardgame',
  entityScope: LibraryEntityScope.release,
  fields: boardgameReleaseWorkspaceFieldDefinitions,
  columns: boardgameReleaseWorkspaceColumnDefinitions,
  sorts: boardgameReleaseWorkspaceSortDefinitions,
  groups: boardgameReleaseWorkspaceGroupDefinitions,
  primaryColumn: BoardGameFieldIds.publisher,
  defaultVisibleColumns: boardgameReleaseWorkspaceDefaultVisibleColumns,
  defaultSort: BoardGameSortIds.releaseDate,
  defaultGroup: BoardGameGroupIds.publisher,
  preferenceCodec: const BoardGamePreferenceCodec(),
);

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
