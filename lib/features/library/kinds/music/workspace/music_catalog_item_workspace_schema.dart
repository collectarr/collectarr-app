import 'music_workspace_groups.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_item_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_schema_support.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:flutter/material.dart';

final musicCatalogItemWorkspaceSchema =
    LibraryWorkspaceSchema<MusicKind, MusicWorkspaceProjection>(
  kindNamespace: 'music',
  fields: [
    MusicCatalogItemWorkspaceFields.title,
    MusicCatalogItemWorkspaceFields.artist,
    MusicCatalogItemWorkspaceFields.publisher,
    MusicCatalogItemWorkspaceFields.barcode,
    MusicCatalogItemWorkspaceFields.catalogNumber,
    MusicCatalogItemWorkspaceFields.genre,
    MusicCatalogItemWorkspaceFields.format,
    MusicCatalogItemWorkspaceFields.releaseDate,
    MusicCatalogItemWorkspaceFields.trackCount,
    MusicCatalogItemWorkspaceFields.listenCount,
    MusicCatalogItemWorkspaceFields.lastListened,
    MusicCatalogItemWorkspaceFields.status,
    MusicCatalogItemWorkspaceFields.cover,
  ],
  columns: [
    musicStatusColumn(field: MusicCatalogItemWorkspaceFields.status),
    musicCoverColumn(field: MusicCatalogItemWorkspaceFields.cover),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCatalogItemWorkspaceFields.artist,
      defaultWidth: 160,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCatalogItemWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCatalogItemWorkspaceFields.genre,
      defaultWidth: 150,
    ),
    musicAlbumDateColumn(
      field: MusicCatalogItemWorkspaceFields.releaseDate,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicCatalogItemWorkspaceFields.trackCount,
      defaultWidth: 90,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicCatalogItemWorkspaceFields.listenCount,
      defaultWidth: 110,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
      MusicCatalogItemWorkspaceFields.lastListened,
      cellValue: (context) => Text(
        formatMusicDate(context.dto.lastListened),
      ),
      defaultWidth: 118,
    ),
  ],
  sorts: [
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicCatalogItemWorkspaceFields.artist,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicCatalogItemWorkspaceFields.title,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicCatalogItemWorkspaceFields.releaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicCatalogItemWorkspaceFields.trackCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicCatalogItemWorkspaceFields.listenCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicCatalogItemWorkspaceFields.lastListened,
      defaultAscending: false,
    ),
  ],
  groups: musicWorkspaceGroupDefinitions(includePersonal: false),
  primaryColumn: MusicCatalogItemWorkspaceFields.title.id,
  defaultVisibleColumns: {
    MusicFieldIds.status,
    MusicFieldIds.cover,
    MusicFieldIds.artist,
    MusicFieldIds.title,
    MusicFieldIds.genre,
    MusicFieldIds.releaseDate,
    MusicFieldIds.trackCount,
    MusicFieldIds.listenCount,
    MusicFieldIds.lastListened,
  },
  defaultSort: MusicSortIds.artist,
  defaultGroup: MusicGroupIds.artist,
);
