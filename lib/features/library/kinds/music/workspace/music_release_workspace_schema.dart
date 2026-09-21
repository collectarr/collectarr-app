import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_fields.dart';
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
    MusicWorkspaceFields.title,
    MusicWorkspaceFields.artist,
    MusicWorkspaceFields.publisher,
    MusicWorkspaceFields.releaseDate,
    MusicWorkspaceFields.trackCount,
    MusicWorkspaceFields.barcode,
    MusicWorkspaceFields.catalogNumber,
    MusicWorkspaceFields.format,
    MusicWorkspaceFields.releaseType,
    MusicWorkspaceFields.releaseStatus,
    MusicWorkspaceFields.country,
    MusicWorkspaceFields.language,
    MusicWorkspaceFields.packaging,
    MusicWorkspaceFields.boxSet,
    MusicWorkspaceFields.discCount,
    MusicWorkspaceFields.listenCount,
    MusicWorkspaceFields.lastListened,
  ],
  columns: [
    musicStatusColumn(),
    musicCoverColumn(),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.artist,
      defaultWidth: 160,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.publisher,
      defaultWidth: 140,
    ),
    musicReleaseDateColumn(),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicWorkspaceFields.trackCount,
      defaultWidth: 90,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.barcode,
      group: 'Release',
      defaultWidth: 160,
      maxWidth: 260,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.catalogNumber,
      group: 'Release',
      defaultWidth: 120,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.format,
      group: 'Release',
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.releaseType,
      group: 'Release',
      defaultWidth: 110,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.releaseStatus,
      group: 'Release',
      defaultWidth: 120,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.country,
      group: 'Release',
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.language,
      group: 'Release',
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.packaging,
      group: 'Release',
      defaultWidth: 120,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.boxSet,
      group: 'Release',
      defaultWidth: 140,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicWorkspaceFields.discCount,
      group: 'Release',
      isNumeric: true,
      defaultWidth: 80,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicWorkspaceFields.listenCount,
      group: 'Listening',
      defaultWidth: 90,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
      MusicWorkspaceFields.lastListened,
      group: 'Listening',
      cellValue: (context) => Text(
        formatMusicDate(context.dto.lastListened),
      ),
      defaultWidth: 118,
    ),
  ],
  sorts: [
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicWorkspaceFields.artist,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicWorkspaceFields.title,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicWorkspaceFields.publisher,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicWorkspaceFields.releaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicWorkspaceFields.trackCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicWorkspaceFields.discCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicWorkspaceFields.listenCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicWorkspaceFields.lastListened,
      defaultAscending: false,
    ),
  ],
  groups: [
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.artist,
      sidebarTitle: 'Artists',
      icon: Icons.person_outline,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.publisher,
      sidebarTitle: 'Labels',
      icon: Icons.business_outlined,
      supportsBucketManagement: true,
      bucketValueMutator: catalogTransportStringBucketValueMutator(
        ['publisher', 'record_label'],
      ),
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.format,
      sidebarTitle: 'Formats',
      icon: Icons.album_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.boxSet,
      sidebarTitle: 'Box sets',
      icon: Icons.inventory_2_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.country,
      sidebarTitle: 'Countries',
      icon: Icons.public_outlined,
    ),
  ],
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
