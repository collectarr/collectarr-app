import 'package:flutter/material.dart';
import '../music_additional_workspace_fields.dart';
import '../presentation/music_workspace_formatting.dart';
import '../music_catalog_workspace_fields.dart';
import '../music_workspace_fields.dart';
import '../music_workspace_dto.dart';
import 'music_workspace_columns.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

final musicCatalogWorkspaceColumns =
    <LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, Object?>>[
  for (final field in MusicAdditionalWorkspaceFields.catalog)
    columnFromField(field,
        group: field.id.value.startsWith('music.has_') ? 'Images' : 'Main',
        isNumeric: field.metadata.valueType.name == 'number' ||
            field.metadata.valueType.name == 'partialDate',
        cellValue: (c) => Text(
            field == MusicAdditionalWorkspaceFields.originalReleaseDate
                ? formatMusicPartialDate(c.dto.music.originalReleaseDateParts)
                : formatMusicCell(field.getValue(c))),
        defaultWidth: 118),
  for (final field in [
    MusicCatalogWorkspaceFields.discFormat,
    MusicCatalogWorkspaceFields.discFormatFamily,
    MusicCatalogWorkspaceFields.recordingDate,
    MusicCatalogWorkspaceFields.recordingMonth,
    MusicCatalogWorkspaceFields.recordingYear,
    MusicCatalogWorkspaceFields.recordingLocation,
    MusicCatalogWorkspaceFields.liveStudio,
    MusicCatalogWorkspaceFields.discSpars,
    MusicCatalogWorkspaceFields.discSound,
    MusicCatalogWorkspaceFields.discColor,
    MusicCatalogWorkspaceFields.discRpm,
    MusicCatalogWorkspaceFields.country,
    MusicCatalogWorkspaceFields.packaging,
    MusicCatalogWorkspaceFields.boxSet,
    MusicCatalogWorkspaceFields.creditContributor,
    MusicCatalogWorkspaceFields.creditRole,
    MusicCatalogWorkspaceFields.creditInstrument,
    MusicCatalogWorkspaceFields.trackComposition,
  ])
    columnFromField(field,
        cellValue: (c) => Text(formatMusicCell(field.getValue(c))),
        group: field.id.value.contains('credit') ? 'Credits' : 'Edition',
        defaultWidth: 150),
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
    isNumeric: true,
    defaultWidth: 80,
  ),
  columnFromField<MusicKind, MusicWorkspaceProjection, Iterable<String>>(
    MusicCatalogWorkspaceFields.genre,
    cellValue: (context) => Text(
      MusicCatalogWorkspaceFields.genre.getValue(context).join(' | '),
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
