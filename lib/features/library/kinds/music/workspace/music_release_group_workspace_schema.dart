import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_schema_support.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:flutter/material.dart';

final _musicWorkFields = musicWorkspaceFieldsForScope(LibraryEntityScope.work);

final musicReleaseGroupWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MusicKind, MusicWorkspaceProjection>(
  kindNamespace: 'music',
  entityScope: LibraryEntityScope.work,
  fields: [
    _musicWorkFields.title,
    _musicWorkFields.artist,
    _musicWorkFields.genre,
    _musicWorkFields.releaseDate,
    _musicWorkFields.releaseCount,
    _musicWorkFields.trackCount,
    _musicWorkFields.aggregateListenCount,
    _musicWorkFields.aggregateLastListened,
    _musicWorkFields.listenedReleaseCount,
  ],
  columns: [
    musicStatusColumn(),
    musicCoverColumn(),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicWorkFields.artist,
      defaultWidth: 160,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicWorkFields.title,
      defaultWidth: 260,
      maxWidth: 520,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicWorkFields.genre,
      defaultWidth: 150,
    ),
    musicReleaseDateColumn(field: _musicWorkFields.releaseDate),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      _musicWorkFields.releaseCount,
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      _musicWorkFields.trackCount,
      defaultWidth: 90,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      _musicWorkFields.aggregateListenCount,
      defaultWidth: 110,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
      _musicWorkFields.aggregateLastListened,
      cellValue: (context) => Text(
        formatMusicDate(context.dto.aggregateLastListened),
      ),
      defaultWidth: 118,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      _musicWorkFields.listenedReleaseCount,
      defaultWidth: 110,
    ),
  ],
  sorts: [
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      _musicWorkFields.artist,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      _musicWorkFields.title,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      _musicWorkFields.releaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      _musicWorkFields.releaseCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      _musicWorkFields.trackCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      _musicWorkFields.aggregateListenCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      _musicWorkFields.aggregateLastListened,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      _musicWorkFields.listenedReleaseCount,
      defaultAscending: false,
    ),
  ],
  groups: [
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicWorkFields.artist,
      sidebarTitle: 'Artists',
      icon: Icons.person_outline,
      supportsBucketManagement: true,
      bucketValueMutator: catalogTransportStringBucketValueMutator(['artist']),
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicWorkFields.genre,
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
