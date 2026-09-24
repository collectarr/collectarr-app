import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_release_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_schema_support.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:flutter/material.dart';

final musicReleaseWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MusicKind, MusicWorkspaceProjection>(
  kindNamespace: 'music',
  entityScope: LibraryEntityScope.release,
  fields: [
    MusicReleaseWorkspaceFields.title,
    MusicReleaseWorkspaceFields.artist,
    MusicReleaseWorkspaceFields.publisher,
    MusicReleaseWorkspaceFields.releaseDate,
    MusicReleaseWorkspaceFields.trackCount,
    MusicReleaseWorkspaceFields.barcode,
    MusicReleaseWorkspaceFields.catalogNumber,
    MusicReleaseWorkspaceFields.format,
    MusicReleaseWorkspaceFields.releaseType,
    MusicReleaseWorkspaceFields.releaseStatus,
    MusicReleaseWorkspaceFields.country,
    MusicReleaseWorkspaceFields.language,
    MusicReleaseWorkspaceFields.packaging,
    MusicReleaseWorkspaceFields.boxSet,
    MusicReleaseWorkspaceFields.discCount,
    MusicReleaseWorkspaceFields.listenCount,
    MusicReleaseWorkspaceFields.lastListened,
    MusicReleaseWorkspaceFields.status,
    MusicReleaseWorkspaceFields.cover,
  ],
  columns: [
    musicStatusColumn(field: MusicReleaseWorkspaceFields.status),
    musicCoverColumn(field: MusicReleaseWorkspaceFields.cover),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.artist,
      defaultWidth: 160,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.publisher,
      defaultWidth: 140,
    ),
    musicReleaseDateColumn(field: MusicReleaseWorkspaceFields.releaseDate),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicReleaseWorkspaceFields.trackCount,
      defaultWidth: 90,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.barcode,
      group: 'Release',
      defaultWidth: 160,
      maxWidth: 260,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.catalogNumber,
      group: 'Release',
      defaultWidth: 120,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.format,
      group: 'Release',
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.releaseType,
      group: 'Release',
      defaultWidth: 110,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.releaseStatus,
      group: 'Release',
      defaultWidth: 120,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.country,
      group: 'Release',
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.language,
      group: 'Release',
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.packaging,
      group: 'Release',
      defaultWidth: 120,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.boxSet,
      group: 'Release',
      defaultWidth: 140,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicReleaseWorkspaceFields.discCount,
      group: 'Release',
      isNumeric: true,
      defaultWidth: 80,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicReleaseWorkspaceFields.listenCount,
      group: 'Listening',
      defaultWidth: 90,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
      MusicReleaseWorkspaceFields.lastListened,
      group: 'Listening',
      cellValue: (context) => Text(
        formatMusicDate(context.dto.lastListened),
      ),
      defaultWidth: 118,
    ),
  ],
  sorts: [
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicReleaseWorkspaceFields.artist,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicReleaseWorkspaceFields.title,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicReleaseWorkspaceFields.publisher,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicReleaseWorkspaceFields.releaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicReleaseWorkspaceFields.trackCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicReleaseWorkspaceFields.discCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicReleaseWorkspaceFields.listenCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicReleaseWorkspaceFields.lastListened,
      defaultAscending: false,
    ),
  ],
  groups: [
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.artist,
      sidebarTitle: 'Artists',
      icon: Icons.person_outline,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.publisher,
      sidebarTitle: 'Labels',
      icon: Icons.business_outlined,
      supportsBucketManagement: true,
      bucketValueMutator: catalogTransportStringBucketValueMutator(
        ['publisher', 'record_label'],
      ),
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.format,
      sidebarTitle: 'Formats',
      icon: Icons.album_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.boxSet,
      sidebarTitle: 'Box sets',
      icon: Icons.inventory_2_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseWorkspaceFields.country,
      sidebarTitle: 'Countries',
      icon: Icons.public_outlined,
    ),
  ],
  primaryColumn: MusicReleaseWorkspaceFields.title.id,
  defaultVisibleColumns: {
    MusicFieldIds.status,
    MusicFieldIds.cover,
    MusicFieldIds.artist,
    MusicFieldIds.title,
    MusicFieldIds.publisher,
    MusicFieldIds.releaseDate,
    MusicFieldIds.trackCount,
    MusicFieldIds.barcode,
    MusicFieldIds.boxSet,
    MusicFieldIds.listenCount,
    MusicFieldIds.lastListened,
  },
  defaultSort: MusicSortIds.artist,
  defaultGroup: MusicGroupIds.artist,
  preferenceCodec: const MusicPreferenceCodec(),
);
