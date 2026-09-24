import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class GameReleaseWorkspaceFields {
  static final publisher = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseDate = dateField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
    entityScope: LibraryEntityScope.release,
  );

  static final barcode = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.barcode,
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
    entityScope: LibraryEntityScope.release,
  );

  static final edition = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.edition,
    label: 'Edition',
    getValue: (dto) => dto.edition,
    entityScope: LibraryEntityScope.release,
  );
}

final gameReleaseWorkspaceFieldDefinitions = [
  GameReleaseWorkspaceFields.publisher,
  GameReleaseWorkspaceFields.releaseDate,
  GameReleaseWorkspaceFields.barcode,
  GameReleaseWorkspaceFields.edition,
];

final gameReleaseWorkspaceGroupDefinitions = [
  groupFromField<GameKind, GameWorkspaceDto, String?>(
    GameReleaseWorkspaceFields.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringListBucketValueMutator(
      'publishers',
      scalarMirrorKeys: ['publisher'],
    ),
  ),
];

final gameReleaseWorkspaceSortDefinitions = [
  LibrarySortDefinition<GameKind, GameWorkspaceDto>(
    id: GameSortIds.releaseTitle,
    label: 'Release title',
    entityScope: LibraryEntityScope.release,
    compare: (left, right) => left.dto.title.compareTo(right.dto.title),
  ),
  sortFromField<GameKind, GameWorkspaceDto, String>(
      GameReleaseWorkspaceFields.publisher),
  sortFromField<GameKind, GameWorkspaceDto, DateTime>(
      GameReleaseWorkspaceFields.releaseDate,
      defaultAscending: false),
];

final gameReleaseWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  GameFieldIds.publisher,
  GameFieldIds.releaseDate,
  GameFieldIds.barcode,
};

final gameReleaseWorkspaceColumnDefinitions = [
  columnFromField<GameKind, GameWorkspaceDto, String?>(
      GameReleaseWorkspaceFields.publisher,
      defaultWidth: 140),
  columnFromField<GameKind, GameWorkspaceDto, DateTime?>(
    GameReleaseWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameReleaseWorkspaceFields.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameReleaseWorkspaceFields.edition,
    group: 'Edition',
    defaultWidth: 110,
  ),
];

final gameReleaseWorkspaceSchema =
    LibraryEntityWorkspaceSchema<GameKind, GameWorkspaceDto>(
  kindNamespace: 'game',
  entityScope: LibraryEntityScope.release,
  fields: gameReleaseWorkspaceFieldDefinitions,
  columns: gameReleaseWorkspaceColumnDefinitions,
  sorts: gameReleaseWorkspaceSortDefinitions,
  groups: gameReleaseWorkspaceGroupDefinitions,
  primaryColumn: GameFieldIds.publisher,
  defaultVisibleColumns: gameReleaseWorkspaceDefaultVisibleColumns,
  defaultSort: GameSortIds.releaseDate,
  defaultGroup: GameGroupIds.publisher,
  preferenceCodec: const GamePreferenceCodec(),
);

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
