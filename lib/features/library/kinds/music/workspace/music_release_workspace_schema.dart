import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_schema_support.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:flutter/material.dart';

final _musicReleaseFields =
    musicWorkspaceFieldsForScope(LibraryEntityScope.release);

final musicReleaseWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MusicKind, MusicWorkspaceProjection>(
  kindNamespace: 'music',
  entityScope: LibraryEntityScope.release,
  fields: [
    _musicReleaseFields.title,
    _musicReleaseFields.artist,
    _musicReleaseFields.publisher,
    _musicReleaseFields.releaseDate,
    _musicReleaseFields.trackCount,
    _musicReleaseFields.barcode,
    _musicReleaseFields.catalogNumber,
    _musicReleaseFields.format,
    _musicReleaseFields.releaseType,
    _musicReleaseFields.releaseStatus,
    _musicReleaseFields.country,
    _musicReleaseFields.language,
    _musicReleaseFields.packaging,
    _musicReleaseFields.boxSet,
    _musicReleaseFields.discCount,
    _musicReleaseFields.listenCount,
    _musicReleaseFields.lastListened,
  ],
  columns: [
    musicStatusColumn(),
    musicCoverColumn(),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.artist,
      defaultWidth: 160,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.title,
      defaultWidth: 260,
      maxWidth: 520,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.publisher,
      defaultWidth: 140,
    ),
    musicReleaseDateColumn(field: _musicReleaseFields.releaseDate),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      _musicReleaseFields.trackCount,
      defaultWidth: 90,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.barcode,
      group: 'Release',
      defaultWidth: 160,
      maxWidth: 260,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.catalogNumber,
      group: 'Release',
      defaultWidth: 120,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.format,
      group: 'Release',
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.releaseType,
      group: 'Release',
      defaultWidth: 110,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.releaseStatus,
      group: 'Release',
      defaultWidth: 120,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.country,
      group: 'Release',
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.language,
      group: 'Release',
      defaultWidth: 100,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.packaging,
      group: 'Release',
      defaultWidth: 120,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.boxSet,
      group: 'Release',
      defaultWidth: 140,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      _musicReleaseFields.discCount,
      group: 'Release',
      isNumeric: true,
      defaultWidth: 80,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      _musicReleaseFields.listenCount,
      group: 'Listening',
      defaultWidth: 90,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
      _musicReleaseFields.lastListened,
      group: 'Listening',
      cellValue: (context) => Text(
        formatMusicDate(context.dto.lastListened),
      ),
      defaultWidth: 118,
    ),
  ],
  sorts: [
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      _musicReleaseFields.artist,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      _musicReleaseFields.title,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      _musicReleaseFields.publisher,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      _musicReleaseFields.releaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      _musicReleaseFields.trackCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      _musicReleaseFields.discCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      _musicReleaseFields.listenCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      _musicReleaseFields.lastListened,
      defaultAscending: false,
    ),
  ],
  groups: [
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.artist,
      sidebarTitle: 'Artists',
      icon: Icons.person_outline,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.publisher,
      sidebarTitle: 'Labels',
      icon: Icons.business_outlined,
      supportsBucketManagement: true,
      bucketValueMutator: catalogTransportStringBucketValueMutator(
        ['publisher', 'record_label'],
      ),
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.format,
      sidebarTitle: 'Formats',
      icon: Icons.album_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.boxSet,
      sidebarTitle: 'Box sets',
      icon: Icons.inventory_2_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicReleaseFields.country,
      sidebarTitle: 'Countries',
      icon: Icons.public_outlined,
    ),
  ],
  primaryColumn: _musicReleaseFields.title.id,
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
