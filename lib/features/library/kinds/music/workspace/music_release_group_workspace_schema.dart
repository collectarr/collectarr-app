import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_schema_support.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:flutter/material.dart';

final musicReleaseGroupWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MusicKind, MusicWorkspaceProjection>(
  kindNamespace: 'music',
  entityScope: LibraryEntityScope.work,
  fields: [
    MusicWorkspaceFields.title,
    MusicWorkspaceFields.artist,
    MusicWorkspaceFields.genre,
    MusicWorkspaceFields.releaseDate,
    MusicWorkspaceFields.releaseCount,
    MusicWorkspaceFields.trackCount,
    MusicWorkspaceFields.aggregateListenCount,
    MusicWorkspaceFields.aggregateLastListened,
    MusicWorkspaceFields.listenedReleaseCount,
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
      MusicWorkspaceFields.genre,
      defaultWidth: 150,
    ),
    musicReleaseDateColumn(),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicWorkspaceFields.releaseCount,
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicWorkspaceFields.trackCount,
      defaultWidth: 90,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicWorkspaceFields.aggregateListenCount,
      defaultWidth: 110,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
      MusicWorkspaceFields.aggregateLastListened,
      cellValue: (context) => Text(
        formatMusicDate(context.dto.aggregateLastListened),
      ),
      defaultWidth: 118,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicWorkspaceFields.listenedReleaseCount,
      defaultWidth: 110,
    ),
  ],
  sorts: [
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicWorkspaceFields.artist,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicWorkspaceFields.title,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicWorkspaceFields.releaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicWorkspaceFields.releaseCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicWorkspaceFields.trackCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicWorkspaceFields.aggregateListenCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicWorkspaceFields.aggregateLastListened,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicWorkspaceFields.listenedReleaseCount,
      defaultAscending: false,
    ),
  ],
  groups: [
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.artist,
      sidebarTitle: 'Artists',
      icon: Icons.person_outline,
      supportsBucketManagement: true,
      bucketValueMutator: catalogTransportStringBucketValueMutator(['artist']),
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.genre,
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
    MusicFieldIds.aggregateListenCount,
    MusicFieldIds.aggregateLastListened,
    MusicFieldIds.listenedReleaseCount,
  },
  defaultSort: MusicSortIds.artist,
  defaultGroup: MusicGroupIds.artist,
  preferenceCodec: const MusicPreferenceCodec(),
);
