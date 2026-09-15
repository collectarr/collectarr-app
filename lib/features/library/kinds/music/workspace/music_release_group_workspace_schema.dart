import 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_schema_support.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:flutter/material.dart';

final musicReleaseGroupWorkspaceSchema =
    LibraryKindSchema<MusicKind, MusicWorkspaceDto>(
  kindNamespace: 'music',
  fields: [
    MusicKindSchema.title,
    MusicKindSchema.artist,
    MusicKindSchema.genre,
    MusicKindSchema.releaseDate,
    MusicKindSchema.releaseCount,
    MusicKindSchema.trackCount,
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
      MusicKindSchema.genre,
      defaultWidth: 150,
    ),
    musicReleaseDateColumn(),
    columnFromField<MusicKind, MusicWorkspaceDto, num?>(
      MusicKindSchema.releaseCount,
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, num?>(
      MusicKindSchema.trackCount,
      defaultWidth: 90,
    ),
  ],
  sorts: [
    sortFromField<MusicKind, MusicWorkspaceDto, String>(MusicKindSchema.artist),
    sortFromField<MusicKind, MusicWorkspaceDto, String>(MusicKindSchema.title),
    sortFromField<MusicKind, MusicWorkspaceDto, DateTime>(
      MusicKindSchema.releaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, num>(
      MusicKindSchema.releaseCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, num>(
      MusicKindSchema.trackCount,
      defaultAscending: false,
    ),
  ],
  groups: [
    groupFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.artist,
      sidebarTitle: 'Artists',
      icon: Icons.person_outline,
      supportsBucketManagement: true,
      bucketValueMutator: catalogTransportStringBucketValueMutator(['artist']),
    ),
    groupFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.genre,
      sidebarTitle: 'Genres',
      icon: Icons.local_offer_outlined,
    ),
  ],
  defaultVisibleColumns: {
    MusicFieldIds.status,
    MusicFieldIds.cover,
    MusicFieldIds.artist,
    MusicFieldIds.title,
    MusicFieldIds.genre,
    MusicFieldIds.releaseDate,
    MusicFieldIds.releaseCount,
    MusicFieldIds.trackCount,
  },
  defaultSort: MusicSortIds.artist,
  defaultGroup: MusicGroupIds.artist,
  preferenceCodec: const MusicPreferenceCodec(),
);
