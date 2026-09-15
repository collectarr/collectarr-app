import 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_schema_support.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:flutter/material.dart';

final musicReleaseWorkspaceSchema =
    LibraryKindSchema<MusicKind, MusicWorkspaceDto>(
  kindNamespace: 'music',
  fields: [
    MusicKindSchema.title,
    MusicKindSchema.artist,
    MusicKindSchema.publisher,
    MusicKindSchema.releaseDate,
    MusicKindSchema.trackCount,
    MusicKindSchema.barcode,
    MusicKindSchema.catalogNumber,
    MusicKindSchema.format,
    MusicKindSchema.releaseType,
    MusicKindSchema.releaseStatus,
    MusicKindSchema.country,
    MusicKindSchema.language,
    MusicKindSchema.packaging,
    MusicKindSchema.boxSet,
    MusicKindSchema.discCount,
    MusicKindSchema.listenCount,
    MusicKindSchema.lastListened,
  ],
  columns: [
    musicStatusColumn(),
    musicCoverColumn(),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.artist,
      defaultWidth: 160,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.title,
      defaultWidth: 260,
      maxWidth: 520,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.publisher,
      defaultWidth: 140,
    ),
    musicReleaseDateColumn(),
    columnFromField<MusicKind, MusicWorkspaceDto, num?>(
      MusicKindSchema.trackCount,
      defaultWidth: 90,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.barcode,
      group: 'Release',
      defaultWidth: 160,
      maxWidth: 260,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.catalogNumber,
      group: 'Release',
      defaultWidth: 120,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.format,
      group: 'Release',
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.releaseType,
      group: 'Release',
      defaultWidth: 110,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.releaseStatus,
      group: 'Release',
      defaultWidth: 120,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.country,
      group: 'Release',
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.language,
      group: 'Release',
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.packaging,
      group: 'Release',
      defaultWidth: 120,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.boxSet,
      group: 'Release',
      defaultWidth: 140,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, num?>(
      MusicKindSchema.discCount,
      group: 'Release',
      isNumeric: true,
      defaultWidth: 80,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, num?>(
      MusicKindSchema.listenCount,
      group: 'Listening',
      defaultWidth: 90,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, DateTime?>(
      MusicKindSchema.lastListened,
      group: 'Listening',
      cellValue: (context) => Text(formatMusicDate(context.dto.lastListened)),
      defaultWidth: 118,
    ),
  ],
  sorts: [
    sortFromField<MusicKind, MusicWorkspaceDto, String>(MusicKindSchema.artist),
    sortFromField<MusicKind, MusicWorkspaceDto, String>(MusicKindSchema.title),
    sortFromField<MusicKind, MusicWorkspaceDto, String>(
      MusicKindSchema.publisher,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, DateTime>(
      MusicKindSchema.releaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, num>(
      MusicKindSchema.trackCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, num>(
      MusicKindSchema.discCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, num>(
      MusicKindSchema.listenCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, DateTime>(
      MusicKindSchema.lastListened,
      defaultAscending: false,
    ),
  ],
  groups: [
    groupFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.artist,
      sidebarTitle: 'Artists',
      icon: Icons.person_outline,
    ),
    groupFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.publisher,
      sidebarTitle: 'Labels',
      icon: Icons.business_outlined,
      supportsBucketManagement: true,
      bucketValueMutator: catalogTransportStringBucketValueMutator(
        ['publisher', 'record_label'],
      ),
    ),
    groupFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.format,
      sidebarTitle: 'Formats',
      icon: Icons.album_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.boxSet,
      sidebarTitle: 'Box sets',
      icon: Icons.inventory_2_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.country,
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
