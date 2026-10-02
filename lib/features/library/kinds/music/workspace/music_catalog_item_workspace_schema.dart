import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_item_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_schema_support.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:flutter/material.dart';

final musicCatalogItemWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MusicKind, MusicWorkspaceProjection>(
  kindNamespace: 'music',
  entityScope: LibraryEntityScope.catalogItem,
  fields: [
    MusicCatalogItemWorkspaceFields.title,
    MusicCatalogItemWorkspaceFields.artist,
    MusicCatalogItemWorkspaceFields.genre,
    MusicCatalogItemWorkspaceFields.releaseDate,
    MusicCatalogItemWorkspaceFields.trackCount,
    MusicCatalogItemWorkspaceFields.listenCount,
    MusicCatalogItemWorkspaceFields.lastListened,
    MusicCatalogItemWorkspaceFields.status,
    MusicCatalogItemWorkspaceFields.cover,
  ],
  columns: [
    musicStatusColumn(field: MusicCatalogItemWorkspaceFields.status),
    musicCoverColumn(field: MusicCatalogItemWorkspaceFields.cover),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCatalogItemWorkspaceFields.artist,
      defaultWidth: 160,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCatalogItemWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCatalogItemWorkspaceFields.genre,
      defaultWidth: 150,
    ),
    musicAlbumDateColumn(
      field: MusicCatalogItemWorkspaceFields.releaseDate,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicCatalogItemWorkspaceFields.trackCount,
      defaultWidth: 90,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicCatalogItemWorkspaceFields.listenCount,
      defaultWidth: 110,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
      MusicCatalogItemWorkspaceFields.lastListened,
      cellValue: (context) => Text(
        formatMusicDate(context.dto.lastListened),
      ),
      defaultWidth: 118,
    ),
  ],
  sorts: [
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicCatalogItemWorkspaceFields.artist,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicCatalogItemWorkspaceFields.title,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicCatalogItemWorkspaceFields.releaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicCatalogItemWorkspaceFields.trackCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicCatalogItemWorkspaceFields.listenCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicCatalogItemWorkspaceFields.lastListened,
      defaultAscending: false,
    ),
  ],
  groups: [
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCatalogItemWorkspaceFields.artist,
      sidebarTitle: 'Artists',
      icon: Icons.person_outline,
      supportsBucketManagement: true,
      bucketValueMutator: catalogTransportStringBucketValueMutator(['artist']),
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCatalogItemWorkspaceFields.genre,
      sidebarTitle: 'Genres',
      icon: Icons.local_offer_outlined,
    ),
  ],
  primaryColumn: MusicCatalogItemWorkspaceFields.title.id,
  defaultVisibleColumns: {
    MusicFieldIds.status,
    MusicFieldIds.cover,
    MusicFieldIds.artist,
    MusicFieldIds.title,
    MusicFieldIds.genre,
    MusicFieldIds.releaseDate,
    MusicFieldIds.trackCount,
    MusicFieldIds.listenCount,
    MusicFieldIds.lastListened,
  },
  defaultSort: MusicSortIds.artist,
  defaultGroup: MusicGroupIds.artist,
  preferenceCodec: const IdentityLibraryWorkspacePreferenceCodec<MusicKind>(),
);
