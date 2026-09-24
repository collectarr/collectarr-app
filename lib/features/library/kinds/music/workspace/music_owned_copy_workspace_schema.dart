import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_owned_copy_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_schema_support.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:flutter/material.dart';

final musicOwnedCopyWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MusicKind, MusicWorkspaceProjection>(
  kindNamespace: 'music',
  entityScope: LibraryEntityScope.copy,
  fields: [
    MusicOwnedCopyWorkspaceFields.title,
    MusicOwnedCopyWorkspaceFields.artist,
    MusicOwnedCopyWorkspaceFields.publisher,
    MusicOwnedCopyWorkspaceFields.condition,
    MusicOwnedCopyWorkspaceFields.grade,
    MusicOwnedCopyWorkspaceFields.location,
    MusicOwnedCopyWorkspaceFields.storage,
    MusicOwnedCopyWorkspaceFields.pricePaid,
    MusicOwnedCopyWorkspaceFields.marketValue,
    MusicOwnedCopyWorkspaceFields.purchaseDate,
    MusicOwnedCopyWorkspaceFields.indexNumber,
    MusicOwnedCopyWorkspaceFields.status,
    MusicOwnedCopyWorkspaceFields.rating,
    MusicOwnedCopyWorkspaceFields.wishlist,
    MusicOwnedCopyWorkspaceFields.updatedAt,
    MusicOwnedCopyWorkspaceFields.addedAt,
    MusicOwnedCopyWorkspaceFields.signedBy,
    MusicOwnedCopyWorkspaceFields.lastCleaned,
  ],
  columns: [
    musicStatusColumn(field: MusicOwnedCopyWorkspaceFields.status),
    musicCoverColumn(field: MusicOwnedCopyWorkspaceFields.cover),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicOwnedCopyWorkspaceFields.artist,
      defaultWidth: 160,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicOwnedCopyWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicOwnedCopyWorkspaceFields.publisher,
      group: 'Release',
      defaultWidth: 140,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicOwnedCopyWorkspaceFields.condition,
      group: 'Copy',
      defaultWidth: 124,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicOwnedCopyWorkspaceFields.grade,
      group: 'Copy',
      defaultWidth: 96,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicOwnedCopyWorkspaceFields.location,
      group: 'Copy',
      defaultWidth: 118,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicOwnedCopyWorkspaceFields.storage,
      group: 'Copy',
      defaultWidth: 150,
    ),
    musicPricePaidColumn(field: MusicOwnedCopyWorkspaceFields.pricePaid),
    musicMarketValueColumn(field: MusicOwnedCopyWorkspaceFields.marketValue),
    musicPurchaseDateColumn(field: MusicOwnedCopyWorkspaceFields.purchaseDate),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicOwnedCopyWorkspaceFields.indexNumber,
      group: 'Copy',
      isNumeric: true,
      defaultWidth: 96,
    ),
    musicRatingColumn(field: MusicOwnedCopyWorkspaceFields.rating),
    musicWishlistColumn(field: MusicOwnedCopyWorkspaceFields.wishlist),
    musicUpdatedAtColumn(field: MusicOwnedCopyWorkspaceFields.updatedAt),
    musicAddedAtColumn(field: MusicOwnedCopyWorkspaceFields.addedAt),
    musicSignedByColumn(field: MusicOwnedCopyWorkspaceFields.signedBy),
    musicLastCleanedColumn(field: MusicOwnedCopyWorkspaceFields.lastCleaned),
  ],
  sorts: [
    musicStatusSort(),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicOwnedCopyWorkspaceFields.artist,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicOwnedCopyWorkspaceFields.title,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicOwnedCopyWorkspaceFields.publisher,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicOwnedCopyWorkspaceFields.condition,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicOwnedCopyWorkspaceFields.grade,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicOwnedCopyWorkspaceFields.location,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicOwnedCopyWorkspaceFields.storage,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicOwnedCopyWorkspaceFields.pricePaid,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicOwnedCopyWorkspaceFields.marketValue,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicOwnedCopyWorkspaceFields.purchaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicOwnedCopyWorkspaceFields.indexNumber,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicOwnedCopyWorkspaceFields.updatedAt,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicOwnedCopyWorkspaceFields.addedAt,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicOwnedCopyWorkspaceFields.lastCleaned,
      defaultAscending: false,
    ),
  ],
  groups: [
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicOwnedCopyWorkspaceFields.artist,
      sidebarTitle: 'Artists',
      icon: Icons.person_outline,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicOwnedCopyWorkspaceFields.publisher,
      sidebarTitle: 'Labels',
      icon: Icons.business_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicOwnedCopyWorkspaceFields.condition,
      sidebarTitle: 'Conditions',
      icon: Icons.verified_outlined,
      supportsBucketManagement: true,
      ownedBucketValueMutator:
          MusicOwnedCopyWorkspaceFields.conditionBucketValueMutator(),
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicOwnedCopyWorkspaceFields.grade,
      sidebarTitle: 'Grades',
      icon: Icons.stars_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicOwnedCopyWorkspaceFields.location,
      sidebarTitle: 'Locations',
      icon: Icons.place_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicOwnedCopyWorkspaceFields.storage,
      sidebarTitle: 'Storage',
      icon: Icons.shelves,
    ),
  ],
  primaryColumn: MusicOwnedCopyWorkspaceFields.title.id,
  defaultVisibleColumns: {
    MusicFieldIds.status,
    MusicFieldIds.cover,
    MusicFieldIds.artist,
    MusicFieldIds.title,
    MusicFieldIds.condition,
    MusicFieldIds.grade,
    MusicFieldIds.location,
    MusicFieldIds.storage,
    MusicFieldIds.pricePaid,
    MusicFieldIds.marketValue,
    MusicFieldIds.purchaseDate,
    MusicFieldIds.indexNumber,
    MusicFieldIds.rating,
    MusicFieldIds.updatedAt,
  },
  defaultSort: MusicSortIds.artist,
  defaultGroup: MusicGroupIds.artist,
  preferenceCodec: const MusicPreferenceCodec(),
);
