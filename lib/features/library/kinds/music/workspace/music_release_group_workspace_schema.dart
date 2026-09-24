import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_release_group_workspace_fields.dart';
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
    MusicReleaseGroupWorkspaceFields.title,
    MusicReleaseGroupWorkspaceFields.artist,
    MusicReleaseGroupWorkspaceFields.genre,
    MusicReleaseGroupWorkspaceFields.releaseDate,
    MusicReleaseGroupWorkspaceFields.releaseCount,
    MusicReleaseGroupWorkspaceFields.trackCount,
    MusicReleaseGroupWorkspaceFields.aggregateListenCount,
    MusicReleaseGroupWorkspaceFields.aggregateLastListened,
    MusicReleaseGroupWorkspaceFields.listenedReleaseCount,
    MusicReleaseGroupWorkspaceFields.status,
    MusicReleaseGroupWorkspaceFields.cover,
  ],
  columns: [
    musicStatusColumn(field: MusicReleaseGroupWorkspaceFields.status),
    musicCoverColumn(field: MusicReleaseGroupWorkspaceFields.cover),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseGroupWorkspaceFields.artist,
      defaultWidth: 160,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseGroupWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseGroupWorkspaceFields.genre,
      defaultWidth: 150,
    ),
    musicReleaseDateColumn(
      field: MusicReleaseGroupWorkspaceFields.releaseDate,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicReleaseGroupWorkspaceFields.releaseCount,
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicReleaseGroupWorkspaceFields.trackCount,
      defaultWidth: 90,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicReleaseGroupWorkspaceFields.aggregateListenCount,
      defaultWidth: 110,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
      MusicReleaseGroupWorkspaceFields.aggregateLastListened,
      cellValue: (context) => Text(
        formatMusicDate(context.dto.aggregateLastListened),
      ),
      defaultWidth: 118,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicReleaseGroupWorkspaceFields.listenedReleaseCount,
      defaultWidth: 110,
    ),
  ],
  sorts: [
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicReleaseGroupWorkspaceFields.artist,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicReleaseGroupWorkspaceFields.title,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicReleaseGroupWorkspaceFields.releaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicReleaseGroupWorkspaceFields.releaseCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicReleaseGroupWorkspaceFields.trackCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicReleaseGroupWorkspaceFields.aggregateListenCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicReleaseGroupWorkspaceFields.aggregateLastListened,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicReleaseGroupWorkspaceFields.listenedReleaseCount,
      defaultAscending: false,
    ),
  ],
  groups: [
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseGroupWorkspaceFields.artist,
      sidebarTitle: 'Artists',
      icon: Icons.person_outline,
      supportsBucketManagement: true,
      bucketValueMutator: catalogTransportStringBucketValueMutator(['artist']),
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicReleaseGroupWorkspaceFields.genre,
      sidebarTitle: 'Genres',
      icon: Icons.local_offer_outlined,
    ),
  ],
  primaryColumn: MusicReleaseGroupWorkspaceFields.title.id,
  defaultVisibleColumns: {
    MusicFieldIds.status,
    MusicFieldIds.cover,
    MusicFieldIds.artist,
    MusicFieldIds.title,
    MusicFieldIds.genre,
    MusicFieldIds.releaseGroupReleaseDate,
    MusicFieldIds.releaseCount,
    MusicFieldIds.releaseGroupTrackCount,
    MusicFieldIds.aggregateListenCount,
    MusicFieldIds.aggregateLastListened,
    MusicFieldIds.listenedReleaseCount,
  },
  defaultSort: MusicSortIds.artist,
  defaultGroup: MusicGroupIds.artist,
  preferenceCodec: const MusicPreferenceCodec(),
);
