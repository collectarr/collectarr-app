import 'music_workspace_groups.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_fields.dart';
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
    ...MusicCatalogWorkspaceFields.all,
    MusicWorkspaceFields.status,
    MusicWorkspaceFields.cover,
  ],
  columns: [
    musicStatusColumn(field: MusicWorkspaceFields.status),
    musicCoverColumn(field: MusicWorkspaceFields.cover),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCatalogWorkspaceFields.artistSummary,
      defaultWidth: 160,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCatalogWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, Iterable<String>>(
      MusicCatalogWorkspaceFields.genre,
      cellValue: (context) => Text(
        MusicCatalogWorkspaceFields.genre.getValue(context).join(', '),
      ),
      defaultWidth: 150,
    ),
    musicAlbumDateColumn(
      field: MusicCatalogWorkspaceFields.releaseDate,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicCatalogWorkspaceFields.trackCount,
      defaultWidth: 90,
    ),
  ],
  sorts: [
    if (MusicFieldIdentities.artistSummary.sortable)
      sortFromField<MusicKind, MusicWorkspaceProjection, String>(
        MusicCatalogWorkspaceFields.artistSummary,
      ),
    if (MusicFieldIdentities.title.sortable)
      sortFromField<MusicKind, MusicWorkspaceProjection, String>(
        MusicCatalogWorkspaceFields.title,
      ),
    if (MusicFieldIdentities.releaseDate.sortable)
      sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
        MusicCatalogWorkspaceFields.releaseDate,
        defaultAscending: false,
      ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicCatalogWorkspaceFields.trackCount,
      defaultAscending: false,
    ),
  ],
  groups: musicWorkspaceGroupDefinitions(includePersonal: false),
  primaryColumn: MusicCatalogWorkspaceFields.title.id,
  defaultVisibleColumns: {
    MusicFieldIds.status,
    MusicFieldIds.cover,
    MusicFieldIds.artistSummary,
    MusicFieldIds.title,
    MusicFieldIds.genre,
    MusicFieldIds.releaseDate,
    MusicFieldIds.trackCount,
  },
  defaultSort: MusicSortIds.artistSummary,
  defaultGroup: MusicGroupIds.artist,
);
