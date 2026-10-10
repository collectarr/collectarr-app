import 'package:flutter/material.dart';
import '../music_catalog_workspace_fields.dart';
import '../music_workspace_fields.dart';
import '../music_workspace_dto.dart';
import 'music_workspace_columns.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

final musicCatalogWorkspaceColumns =
    <LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, Object?>>[
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
  musicAlbumDateColumn(
    field: MusicCatalogWorkspaceFields.releaseDate,
  ),
  columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
    MusicCatalogWorkspaceFields.discCount,
    isNumeric: true,
    defaultWidth: 70,
  ),
  columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
    MusicCatalogWorkspaceFields.trackCount,
    isNumeric: true,
    defaultWidth: 70,
  ),
  columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
    MusicCatalogWorkspaceFields.length,
    defaultWidth: 80,
  ),
  columnFromField<MusicKind, MusicWorkspaceProjection, Iterable<String>>(
    MusicCatalogWorkspaceFields.genre,
    cellValue: (context) => Text(
      MusicCatalogWorkspaceFields.genre.getValue(context).join(', '),
    ),
    defaultWidth: 150,
  ),
  columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCatalogWorkspaceFields.publisher,
      defaultWidth: 140),
  columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCatalogWorkspaceFields.catalogNumber,
      defaultWidth: 130),
  columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCatalogWorkspaceFields.barcode,
      defaultWidth: 140),
  columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCatalogWorkspaceFields.formatSummary,
      defaultWidth: 150),
];
